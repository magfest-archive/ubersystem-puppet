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
  }

  # where our backend (rams) listens on it's internal port
  $backend_base_url = "http://localhost:${socket_port}"

  nginx::resource::location { "rams_backend":
    location => "/${url_prefix}/",
    ensure   => present,
    proxy    => "${backend_base_url}/${url_prefix}/",
    vhost    => "rams-normal",
    ssl      => true,
    proxy_redirect => 'http://localhost/ $scheme://$host:$server_port/',
    notify   => Service["nginx"],
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
