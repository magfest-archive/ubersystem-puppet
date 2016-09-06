class uber::db_replication_master (
  $replication_user = 'replicator',
  $replication_password,
  $allow_to_hosts,
) {
  if $replication_password == '' {
    fail("can't do database replication without setting a replication passwd")
  }

  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, $replication_password),
    replication   => true,
  }

  $allow_to_hosts_hash = generate_resource_hash($allow_to_hosts, 'name', 'allow replication from host ')
  $allow_to_hosts_defaults = {
    username => $replication_user,
  }

  create_resources(uber::allow_replication_from, $allow_to_hosts_hash, $allow_to_hosts_defaults)

  class { 'uber::db_replication_master_config':
    notify  => Service['postgresql'],
  }
}

class uber::db_replication_master_config {
  postgresql::server::config_entry {
     'listen_address':       value => "*";
     'wal_level':            value => 'hot_standby';
     'max_wal_senders':      value => '3';
     'checkpoint_segments':  value => '8';
     'wal_keep_segments':    value => '8';
  }
}

define uber::allow_replication_from (
  $username,
) {
  postgresql::server::pg_hba_rule { "rep access for ${name}":
    description => "Open up postgresql for access from ${name}",
    type        => 'hostssl',
    database    => 'replication',   # replication connections do not specify any particular database
    user        => $username,
    address     => "${name}",
    auth_method => 'md5',
  }

  # open this port on the firewall for this IP
  ufw::allow { "allow postgres replication from $name":
    from  => get_ip_addr($name),
    proto => 'tcp',
    port  => 5432,
  }
}
