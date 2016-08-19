class uber::firewall (
  $ssl_port = hiera('uber::ssl_port'),
  $ssl_api_port = hiera('uber::ssl_api_port'),
  $socket_port = hiera('uber::socket_port'),
  $http_port = '80',
  $open_backend_port = false,
  $blacklisted_ips = hiera('uber::firewall_blacklisted_ips')
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

    $rule_hash = generate_resource_hash($blacklisted_ips, 'ip', 'blacklist deny from IP ')

    $rule_defaults = {}
    create_resources(ufw::deny, $rule_hash, $rule_defaults)
  }
}
