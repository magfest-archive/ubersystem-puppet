class uber::firewall (
  $ssl_port = hiera('uber::ssl_port'),
  $ssl_api_port = hiera('uber::ssl_api_port'),
  $socket_port = hiera('uber::socket_port'),
  $http_port = '80',
  $open_backend_port = false,
) {
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    include ufw

    if $open_backend_port {
      ufw::allow { "${title}-rawport":
        port => $socket_port,
      }
    }

    ufw::allow { "${title}-ssl":
      port => $ssl_port,
    }

    ufw::allow { "${title}-ssl-api":
      port => $ssl_api_port,
    }

    ufw::allow { "${title}-http":
      port => $http_port,
    }
  }
}
