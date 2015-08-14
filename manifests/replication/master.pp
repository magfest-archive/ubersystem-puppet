class uber::replication::master (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $slave_ips,
) {
  require uber::db

  if $replication_password == '' {
    fail("can't do database replication without setting a replication passwd")
  }

  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, $replication_password),
    replication   => true,
    subscribe      => Postgresql::Server::Db["${dbname}"]
  }

  postgresql::server::config_entry {
     # 'listen_address':       value => "*";
     'wal_level':            value => 'hot_standby';
     'max_wal_senders':      value => '3';
     'checkpoint_segments':  value => '8';
     'wal_keep_segments':    value => '8';
  }

  uber::replication::allow-from-ip { $slave_ips:
    dbname   => $dbname,
    username => $replication_user,
  }
}

class uber::replication::allow-from-ip (
  $dbname,
  $username,
) {
  postgresql::server::pg_hba_rule { "rep access for ${name}":
    description => "Open up postgresql for access from ${name}",
    type        => 'hostssl',
    database    => 'replication', #$dbname,
    user        => $username,
    address     => "${name}/32",
    auth_method => 'md5',
  }

  # open this port on the firewall for this IP
  ufw::allow { "allow postgres from $name":
    from  => "$name",
    proto => 'tcp',
    port  => 5432,
  }
}
