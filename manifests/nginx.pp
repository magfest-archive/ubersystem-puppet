class uber::nginx (
  $hostname = $uber::hostname,
  $ssl_crt_bundle = 'puppet:///modules/uber/selfsigned-testonly.crt',
  $ssl_crt_key = 'puppet:///modules/uber/selfsigned-testonly.key',
  $ssl_ca_crt = undef, # if set, we enable API access through /jsonrpc
  $ssl_port = hiera('uber::ssl_port'),
  $socket_port = hiera('uber::socket_port'),
  $event_name = hiera("uber::config::event_name"),
  $year = hiera("uber::config::year"),
  $url_prefix = hiera("uber::config::url_prefix"),
) {

  $client_cert_vhost_cfg = undef

  if ($ssl_ca_crt != undef) {
    ensure_resource('file', "${nginx::params::nx_conf_dir}/jsonrpc-client.crt", {
      owner  => $nginx::params::nx_daemon_user,
      mode   => '0444',
      source => $ssl_ca_crt,
      notify => Service["nginx"],
    })

    $client_cert_location_cfg = {
      'ssl_client_certificate' => "${nginx::params::nx_conf_dir}/jsonrpc-client.crt",
      'ssl_verify_client'      => 'optional',
    }
  }

  nginx::resource::vhost { $hostname:
    www_root          => '/var/www/',
    rewrite_to_https  => true,
    ssl               => true,
    ssl_cert          => $ssl_crt_bundle,
    ssl_key           => $ssl_crt_key,
    ssl_port          => $ssl_port,
    vhost_cfg_prepend => $client_cert_location_cfg,
    notify            => Service["nginx"],
  }

  # where our backend (rams) listens internally
  $proxy_url = "http://localhost:${socket_port}/${url_prefix}/"

  nginx::resource::location { "${hostname}":
    ensure   => present,
    proxy    => $proxy_url,
    location => "/${url_prefix}/",
    vhost    => $hostname,
    ssl      => true,
    location_cfg_append => {
        'proxy_redirect' => 'http://localhost/ $scheme://$host:$server_port/'
    },
    notify   => Service["nginx"],
  }

  if ($ssl_ca_crt != undef) {
    nginx::resource::location { "/jsonrpc/":
      ensure   => present,
      ssl_only => true,
      proxy    => "http://localhost:${socket_port}/jsonrpc/",
      vhost    => $hostname,
      ssl      => true,
      location_custom_cfg_prepend => {
        '    if ($ssl_client_verify != "SUCCESS")' => '{ return 403; } # only allow client-cert authenticated requests',
      },
      location_cfg_append => {
        'proxy_redirect' => 'http://localhost/ $scheme://$host:$server_port/',
      },
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