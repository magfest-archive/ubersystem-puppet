class uber::db_replication_slave (
  $replication_user = 'replicator',
  $replication_password,
  $replicate_from,
  $uber_db_util_path = '/usr/local/uberdbutil'
) {
  if $replication_password == '' {
    fail("can't do database replication without setting a replication passwd")
  }

  if $replicate_from == '' {
    fail("can't do DB slave replication without a hostname")
  }

  class { 'uber::db_replication_slave_config':
    notify  => Service['postgresql'],
  }

  file { "${uber_db_util_path}":
    ensure => "directory",
    owner  => "postgres",
    group  => "postgres",
    mode   => 700,
    notify  => File["${uber_db_util_path}/recovery.conf"],
  }

  file { "${uber_db_util_path}/recovery.conf":
    ensure  => present,
    owner   => "postgres",
    group   => "postgres",
    mode    => 600,
    content => template('uber/pg-recovery.conf.erb'),
    notify  => File["${uber_db_util_path}/pg-start-replication.sh"],
  }

  file { "${uber_db_util_path}/pg-start-replication.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber/pg-start-replication.sh.erb'),
    notify => File["${uber_db_util_path}/sync-to-master.sh"],
  }

  file { "${uber_db_util_path}/sync-to-master.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber/pg-sync-to-master.sh.erb'),
  }
}

class uber::db_replication_slave_config {
  postgresql::server::config_entry {
    'wal_level':            value => 'hot_standby';
    'max_wal_senders':      value => '3';
    'checkpoint_segments':  value => '8';
    'wal_keep_segments':    value => '8';
    'hot_standby':          value => 'on';
  }
}