class uber::db (
  $user = hiera('uber::db_user'),
  $pass = hiera('uber::db_pass'),
  $dbname = hiera('uber::db_name'),
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