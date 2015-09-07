class uber::firewall (
  $ssl_port = hiera('uber::ssl_port'),
  $socket_port = hiera('uber::socket_port'),
  $http_port = '80',
  $open_backend_port = false,
) {
  include ufw

  if $open_backend_port {
    ufw::allow { "${title}-rawport":
      port => $socket_port,
    }
  }

  if defined("uber::json_rpc") {
    ufw::allow { "${title}-jsonrpc":
      port => $uber::json_rpc::api_ssl_port,
    }
  }

  ufw::allow { "${title}-ssl":
    port => $ssl_port,
  }

  ufw::allow { "${title}-http":
    port => $http_port,
  }
}
