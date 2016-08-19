class uber::firewall (
  $blacklisted_ips = hiera('uber::firewall_blacklisted_ips')
) {
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    include ufw

    # MUST come first or else rules won't actually be applied
    class { 'uber::firewall_deny_rules':
      deny_ips_list => $blacklisted_ips,
      before => Class['uber::firewall_allow_rules']
    }

    # MUST come second
    class { 'uber::firewall_allow_rules':
    }
  }
}

class uber::firewall_deny_rules($deny_ips_list)
{
  $rule_hash = generate_resource_hash($deny_ips_list, 'ip', 'blacklist deny from IP ')

  $rule_defaults = {}
  create_resources(ufw::deny, $rule_hash, $rule_defaults)
}

class uber::firewall_allow_rules(
  $ssl_port = hiera('uber::ssl_port'),
  $ssl_api_port = hiera('uber::ssl_api_port'),
  $socket_port = hiera('uber::socket_port'),
  $http_port = '80',
  $open_backend_port = false,
)
{
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

  ufw::allow { 'allow-ssh-from-all':
    port => 22,
  }

  # (the IP is blocked if it initiates 6 or more connections within 30 seconds):
  ufw::limit { 22: }
}