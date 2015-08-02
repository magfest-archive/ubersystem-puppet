class uber::nginx (
  $hostname,
  $ssl_crt_bundle,
  $ssl_crt_key,
  $ssl_port,
  $event_name,
  $year,
) {
  nginx::resource::vhost { $hostname:
    www_root    => '/var/www/',
    rewrite_to_https => true,
    ssl              => true,
    ssl_cert         => $ssl_crt_bundle,
    ssl_key          => $ssl_crt_key,
    ssl_port         => $ssl_port,
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