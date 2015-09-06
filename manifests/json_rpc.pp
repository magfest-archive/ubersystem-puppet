# exposes the JSON RPC API with nginx
# CA, server, and client keys must already exist prior to running puppet

class uber::json_rpc (
  $hostname = $uber::hostname,
  $api_ssl_port = 777,
  $ssl_server_crt,
  $ssl_server_key,
  $ssl_ca_crt,
  $url_prefix = hiera("uber::config::url_prefix"),
  $socket_port = hiera('uber::socket_port'),
) {
  require ::uber::nginx

  ensure_resource('file', "${nginx::params::nx_conf_dir}/jsonrpc-client.crt", {
    owner  => $nginx::params::nx_daemon_user,
    mode   => '0444',
    source => $ssl_ca_crt,
  })

  # create a new virtual host listening on another port
  # this will require a specific client certificate to be supplied by the client in order to allow HTTPS
  nginx::resource::vhost { "${uber::hostname}-jsonrpc":
    use_default_location => false,
    server_name      => [$uber::hostname],
    ssl_port         => $api_ssl_port,
    listen_port      => $api_ssl_port,
    ssl              => true,
    ssl_cert         => $ssl_server_crt,
    ssl_key          => $ssl_server_key,
    vhost_cfg_append => {
      'ssl_client_certificate' => "${nginx::params::nx_conf_dir}/jsonrpc-client.crt",
      'ssl_verify_client'      => 'on',
    },
    notify => Service["nginx"],
  }

  nginx::resource::location { "/jsonrpc/":
    ensure   => present,
    ssl_only => true,
    proxy    => "http://localhost:${socket_port}/jsonrpc/",
    vhost    => "${uber::hostname}-jsonrpc",
    ssl      => true,
    location_cfg_append => {
      'proxy_redirect' => 'http://localhost/ $scheme://$host:$server_port/',
    },
    notify   => Service["nginx"],
  }
}