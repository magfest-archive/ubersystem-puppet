class uber::firewall (
  $blacklisted_ips = hiera('uber::firewall_blacklisted_ips')
) {
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    include ufw

    # workaround ufw puppet module inability to order rules correctly. we have to re-create the entire
    # list every time for it to respect our ordering.
    exec { 'ufw-reset':
      command => 'ufw --force reset',
      before  => [Class['uber::firewall_deny_rules'], Exec['ufw-enable'], Exec['ufw-default-deny']]
    }

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
  $rule_hash = generate_resource_hash($deny_ips_list, 'from', 'blacklist deny from IP ')

  $rule_defaults = {
    'ip' => 'any'
  }
  create_resources(ufw::deny, $rule_hash, $rule_defaults)

  # (the IP is blocked if it initiates 6 or more connections within 30 seconds):
  ufw::limit { 22: }
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
}