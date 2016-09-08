class uber::db (
  $user = 'rams',
  $pass = 'rams',
  $dbname = 'rams',
  $db_replication_mode = 'none',
) {
  class { 'postgresql::server':
      ip_mask_deny_postgres_user => '0.0.0.0/32',
      ip_mask_allow_all_users    => '0.0.0.0/0',
      listen_addresses           => '*',          # important: listen on everything but, still need to keep this firewalled
      manage_firewall            => false,        # we're using ufw
  }

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
}