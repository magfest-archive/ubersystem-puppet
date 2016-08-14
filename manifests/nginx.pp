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
    vhost_cfg_prepend => {
      'error_page' => '503 @maintenance',
    },
  }

  # if maintenance.html exists, it will cause everything to redirect there
  nginx::resource::location { "@maintenance":
    ensure           => present,
    notify           => Service["nginx"],
    rewrite_rules    => ['^(.*)$ /maintenance.html break'],
    vhost            => "rams-normal",
    www_root         => "/var/www/"
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
  }

  uber::nginx_custom_location { "rams_backend-static-cached":
    url_prefix       => $url_prefix,
    backend_base_url => $backend_base_url,
    vhost            => "rams-normal",
    subdir           => "static/",
    cached           => true,
  }

  uber::nginx_custom_location { "rams_backend-staticviews-cached":
    url_prefix       => $url_prefix,
    backend_base_url => $backend_base_url,
    vhost            => "rams-normal",
    subdir           => "static_views/",
    cached           => true,
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
        '    if ($ssl_client_verify != "SUCCESS")' => '{ return 403; } # only allow client-cert authenticated requests',
      },
      proxy_redirect => 'http://localhost/ $scheme://$host:$server_port/',
      notify => Service["nginx"],
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
  $cached = false,
) {

  if ($cached) {
    $params = {
      "uber-nginx-location-$name" => {
        location_custom_cfg_prepend => {
          '    proxy_ignore_headers' => 'Cache-Control Set-Cookie;',
        },
      }
    }
  } else {
    $params = {
      "uber-nginx-location-$name" => {
        location_custom_cfg_prepend => {
          '    proxy_no_cache' => '"1";',
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
      '    if (-f $document_root/maintenance.html)' => '{ return 503; }',
    },
    proxy_redirect => 'http://localhost/ $scheme://$host:$server_port/',
  }

  create_resources(nginx::resource::location, $params, $defaults)
}
