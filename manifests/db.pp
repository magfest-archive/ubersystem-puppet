class uber::db (
  $user = 'rams',
  $pass = 'rams',
  $dbname = 'rams',
  $db_replication_mode = 'none',
) {
  if $db_replication_mode != 'slave'
  {
    postgresql::server::db { $dbname:
      user     => $user,
      password => postgresql_password($user, $pass),
      require  => Service['postgresql'],
    }
  }
}