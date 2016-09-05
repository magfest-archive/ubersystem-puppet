class uber::db (
  $user = 'rams',
  $pass = 'rams',
  $dbname = 'rams',
  $db_replication_mode = 'none',
) {
  if $db_replication_mode != 'slave'
  {
    # only create the database if we're not the slave DB, because setting
    # up replication involves deleting the existing database.
    postgresql::server::db { $dbname:
      user     => $user,
      password => postgresql_password($user, $pass),
      require  => Service['postgresql'],
    }
  }

  if $db_replication_mode == 'slave' {
    include uber::db_replication_slave
  } else if $db_replication_mode == 'master' {
    include uber::db_replication_master
  }
}