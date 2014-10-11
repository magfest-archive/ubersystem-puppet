define uber::dbreplicationmaster (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $slave_ips,
) {
  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, $replication_password),
    replication   => true,
    #notify        => Postgresql::Server::Config_Entry['wal_level'],
    subscribe      => Postgresql::Server::Db["${dbname}"]
  }

  postgresql::server::config_entry {
     # 'listen_address':       value => "*";
     'wal_level':            value => 'hot_standby';
     'max_wal_senders':      value => '3';
     'checkpoint_segments':  value => '8';
     'wal_keep_segments':    value => '8';
  }

  uber::allow-replication-from-ip { $slave_ips:
    dbname   => $dbname,
    username => $replication_user,
  }
}
