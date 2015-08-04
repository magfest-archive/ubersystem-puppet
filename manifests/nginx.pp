class uber::nginx (
  $hostname = hiera("uber::hostname"),
  $ssl_crt_bundle = 'puppet:///modules/uber/selfsigned-testonly.crt',
  $ssl_crt_key = 'puppet:///modules/uber/selfsigned-testonly.key',
  $ssl_port = hiera('uber::ssl_port'),
  $socket_port = hiera('uber::socket_port'),
  $event_name = hiera("uber::config::event_name"),
  $year = hiera("uber::config::year"),
  $url_prefix = hiera("uber::config::url_prefix"),
) {
  nginx::resource::vhost { $hostname:
    www_root    => '/var/www/',
    rewrite_to_https => true,
    ssl              => true,
    ssl_cert         => $ssl_crt_bundle,
    ssl_key          => $ssl_crt_key,
    ssl_port         => $ssl_port,
    notify => Service["nginx"],
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
    notify   => [ File["${nginx::params::nx_conf_dir}/conf.d/default.conf"], Service["nginx"] ]
  }

  # delete the default.conf to ensure that our virtualhost file gets the requests for localhost.
  # this is needed if you try and access the server in a browser but not by $hostname_to_use
  file { "${nginx::params::nx_conf_dir}/conf.d/default.conf":
    ensure => absent,
    notify => Service["nginx"],
  }

  file { "/var/www/":
    ensure => "directory",
  }

  file { '/var/www/index.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('uber/root-index.html.erb'),
  }
}