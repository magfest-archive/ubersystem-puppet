class uber::nginx (
  $hostname = $uber::hostname,
  $ssl_crt_bundle = 'puppet:///modules/uber/selfsigned-testonly.crt',
  $ssl_crt_key = 'puppet:///modules/uber/selfsigned-testonly.key',
  $ssl_ca_crt = undef, # if set, we enable API access through /jsonrpc
  $ssl_port = hiera('uber::ssl_port'),
  $ssl_api_port = hiera('uber::ssl_api_port'),
  $socket_port = hiera('uber::socket_port'),
  $event_name = hiera("uber::config::event_name"),
  $year = hiera("uber::config::year"),
  $url_prefix = hiera("uber::config::url_prefix"),
) {

  # setup 2 virtual hosts:
  # 1) for normal HTTP and HTTPS traffic
  # 2) (only if enabled) for API HTTPS traffic that requires a client cert

  # port 80 and $ssl_port(usually 443) vhosts
  nginx::resource::vhost { "rams-normal":
    server_name       => [$hostname],
    www_root          => '/var/www/',
    rewrite_to_https  => true,
    ssl               => true,
    ssl_cert          => $ssl_crt_bundle,
    ssl_key           => $ssl_crt_key,
    ssl_port          => $ssl_port,
    notify            => Service["nginx"],
  }

  # where our backend (rams) listens on it's internal port
  $backend_base_url = "http://localhost:${socket_port}"

  $location_cfg_append = {
    'proxy_redirect' => 'http://localhost/ $scheme://$host:$server_port/'
  }

  nginx::resource::location { "rams_backend":
    location => "/${url_prefix}/",
    ensure   => present,
    proxy    => "${backend_base_url}/${url_prefix}/",
    vhost    => "rams-normal",
    ssl      => true,
    location_cfg_append => $location_cfg_append,
    notify   => Service["nginx"],
  }

  $blackhole_config = {
    'access_log' => 'off',
    'deny'       => 'all'
  }

  # disable a particular page when in "at the con mode" that was causing issues.
  # after m2016, kill this. or, keep it.
  nginx::resource::location { "at_con_mode_hack":
    location => "/${url_prefix}/signups/jobs",
    ensure   => present,
    vhost    => "rams-normal",
    notify   => Service["nginx"],
    www_root            => '/crap_ignore',
    ssl      => true,
    location_cfg_append => $blackhole_config,
  }

  if ($ssl_ca_crt != undef) {
    ensure_resource('file', "${nginx::params::nx_conf_dir}/jsonrpc-client.crt", {
      owner  => $nginx::params::nx_daemon_user,
      mode   => '0444',
      source => $ssl_ca_crt,
      notify => Service["nginx"],
    })

    $client_cert_location_cfg = {
      'ssl_client_certificate' => "${nginx::params::nx_conf_dir}/jsonrpc-client.crt",
      'ssl_verify_client'      => 'on',
    }

    # API virtualhost only for automated HTTPS client-cert-verified connections
    nginx::resource::vhost { "rams-api":
      use_default_location  => false,
      server_name           => [$hostname],
      ssl                   => true,
      ssl_cert              => $ssl_crt_bundle,
      ssl_key               => $ssl_crt_key,
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
      location_cfg_append => $location_cfg_append,
      notify => Service["nginx"],
    }
  }

  # delete the default.conf to ensure that our virtualhost file gets the requests for localhost.
  # this is needed if you try and access the server in a browser but not by $hostname_to_use
  file { "${nginx::params::nx_conf_dir}/conf.d/default.conf":
    ensure => absent,
    notify => Service["nginx"],
  }

  file { "/var/www/":
    ensure => directory,
  }

  file { '/var/www/index.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('uber/root-index.html.erb'),
    require => File["/var/www/"],
  }
}
