class uber::nginx (
  $hostname = $uber::hostname,
  $ssl_crt = 'puppet:///modules/uber/selfsigned-testonly.crt',
  $ssl_key = 'puppet:///modules/uber/selfsigned-testonly.key',
  $ssl_ca_crt = undef, # if set, we enable API access through /jsonrpc
  $ssl_port = hiera('uber::ssl_port'),
  $ssl_api_port = hiera('uber::ssl_api_port'),
  $socket_port = hiera('uber::socket_port'),
  $event_name = hiera("uber::config::event_name"),
  $year = hiera("uber::config::year"),
  $url_prefix = hiera("uber::config::url_prefix"),
  $onsite_uber_address = "",
  $redirect_all_traffic_onsite = false,
) {

  $ssl_crt_filename = "${nginx::params::conf_dir}/ssl-certificate.crt"
  $ssl_key_filename = "${nginx::params::conf_dir}/ssl-certificate.key"

  ensure_resource('file', $ssl_crt_filename, {
    owner  => $nginx::params::daemon_user,
    mode   => '0444',
    source => $ssl_crt,
    notify => Service["nginx"],
  })

  ensure_resource('file', $ssl_key_filename, {
    owner  => $nginx::params::daemon_user,
    mode   => '0440',
    source => $ssl_key,
    notify => Service["nginx"],
  })

  # setup 2 virtual hosts:
  # 1) for normal HTTP and HTTPS traffic
  # 2) (only if enabled) for API HTTPS traffic that requires a client cert

  $proxy_set_header = [
    # original values
    'Host $host',
    'X-Real-IP $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',

    # custom values
    'X-Forwarded-Host  $http_host',
    'X-Forwarded-Proto $scheme',
  ]

  $_vhost_cfg_prepend = {
    'error_page' => '503 @maintenance',
    'root' => '/var/www',  # slightly hacky. need this for maintenance page.
  }

  if ($redirect_all_traffic_onsite) {
    $redirect_line = "301 ${onsite_uber_address}\$request_uri"
    $redirect_cfg = {
      'return' => $redirect_line
    }
    $vhost_cfg_prepend = merge($_vhost_cfg_prepend, $redirect_cfg)
  } else {
    $vhost_cfg_prepend = $_vhost_cfg_prepend
  }

  # port 80 and $ssl_port(usually 443) vhosts
  nginx::resource::vhost { "rams-normal":
    server_name       => [$hostname],
    www_root          => '/var/www/',
    rewrite_to_https  => true,
    ssl               => true,
    ssl_cert          => $ssl_crt_filename,
    ssl_key           => $ssl_key_filename,
    ssl_port          => $ssl_port,
    notify            => Service["nginx"],
    rewrite_rules    => ['^/robots.txt$ /uber/static/robots.txt last'],
    vhost_cfg_prepend => $vhost_cfg_prepend,
  }

  # if maintenance.html exists, it will cause everything to redirect there
  nginx::resource::location { "@maintenance":
    ensure           => present,
    notify           => Service["nginx"],
    rewrite_rules    => ['^(.*)$ /maintenance.html break'],
    vhost            => "rams-normal",
    www_root         => "/var/www/",
    ssl      => true,
  }

  # where our backend (rams) listens on it's internal port
  $backend_base_url = "http://localhost:${socket_port}"

  ensure_resource('file', "/etc/nginx/rams.conf", {
    owner  => $nginx::params::daemon_user,
    mode   => '0444',
    source => 'puppet:///modules/uber/rams.conf',
    notify => Service["nginx"],
  })

  uber::nginx_custom_location { "rams_backend-dontcache":
    url_prefix       => $url_prefix,
    backend_base_url => $backend_base_url,
    vhost            => "rams-normal",
    subdir           => "",
    cached           => false,
    proxy_set_header => $proxy_set_header,
  }

  uber::nginx_custom_location { "rams_backend-static-cached":
    url_prefix       => $url_prefix,
    backend_base_url => $backend_base_url,
    vhost            => "rams-normal",
    subdir           => "static/",
    cached           => true,
    proxy_set_header => $proxy_set_header,
  }

  uber::nginx_custom_location { "rams_backend-staticviews-cached":
    url_prefix       => $url_prefix,
    backend_base_url => $backend_base_url,
    vhost            => "rams-normal",
    subdir           => "static_views/",
    cached           => true,
    proxy_set_header => $proxy_set_header,
  }

  if ($ssl_ca_crt != undef) {
    ensure_resource('file', "${nginx::params::conf_dir}/jsonrpc-client.crt", {
      owner  => $nginx::params::daemon_user,
      mode   => '0440',
      source => $ssl_ca_crt,
      notify => Service["nginx"],
    })

    $client_cert_location_cfg = {
      'ssl_client_certificate' => "${nginx::params::conf_dir}/jsonrpc-client.crt",
      'ssl_verify_client'      => 'on',
    }

    # API virtualhost only for automated HTTPS client-cert-verified connections
    nginx::resource::vhost { "rams-api":
      use_default_location  => false,
      server_name           => [$hostname],
      ssl                   => true,
      ssl_cert              => $ssl_crt_filename,
      ssl_key               => $ssl_key_filename,
      ssl_port              => $ssl_api_port,
      listen_port           => $ssl_api_port,
      vhost_cfg_prepend     => $client_cert_location_cfg,
      notify                => Service["nginx"],
    }

    nginx::resource::location { "rams-api":
      location => "/jsonrpc/",
      ensure   => present,
      ssl_only => true,
      proxy    => "${backend_base_url}/jsonrpc/",
      vhost    => "rams-api",
      ssl      => true,
      location_custom_cfg_prepend => {
        'if ($ssl_client_verify != "SUCCESS")' => '{ return 403; } # only allow client-cert authenticated requests',
      },
      proxy_redirect => 'http://localhost/ $scheme://$http_host/',
      notify => Service["nginx"],
      proxy_set_header => $proxy_set_header,
    }
  }

  file { "/var/www/":
    ensure => directory,
    notify => Service["nginx"],
  }

  file { '/var/www/index.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('uber/root-index.html.erb'),
    require => File["/var/www/"],
    notify => Service["nginx"],
  }
}

define uber::nginx_custom_location(
  $url_prefix,
  $backend_base_url,
  $subdir,
  $vhost,
  $proxy_set_header = [],
  $cached = false,
) {

  if ($cached) {
    $params = {
      "uber-nginx-location-$name" => {
        location_custom_cfg_prepend => {
          'proxy_ignore_headers' => 'Cache-Control Set-Cookie;',
          'proxy_hide_header' => 'Set-Cookie;', # important: static requests should NOT return Set-Cookie to client
        },
      }
    }
  } else {
    $params = {
      "uber-nginx-location-$name" => {
        location_custom_cfg_prepend => {
          'proxy_no_cache' => '"1";',
        },
      }
    }
  }

  $defaults = {
    location => "/${url_prefix}/$subdir",
    ensure   => present,
    proxy    => "${backend_base_url}/${url_prefix}/$subdir",
    vhost    => $vhost,
    ssl      => true,
    include  => ["/etc/nginx/rams.conf"],
    notify   => Service["nginx"],
    location_custom_cfg_append => {
      'if (-f $document_root/maintenance.html)' => '{ return 503; }',
    },
    proxy_redirect => 'http://localhost/ $scheme://$http_host/',
    proxy_set_header => $proxy_set_header,
  }

  create_resources(nginx::resource::location, $params, $defaults)
}
