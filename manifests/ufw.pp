
define uber::firewall (
  $socket_port,
  $open_firewall_port = false,
  $ssl_port,
  $http_port = '80',
) {
  include ufw

  if $open_firewall_port {
    ufw::allow { "${title}-rawport":
      port => $socket_port,
    }
  }

  ufw::allow { "${title}-ssl":
    port => $ssl_port,
  }

  ufw::allow { "${title}-http":
    port => $http_port,
  }
}
