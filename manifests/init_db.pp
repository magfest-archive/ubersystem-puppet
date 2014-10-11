define uber::init_db (
  $venv_python,
  $uber_path,
  $db_replication_mode = 'none',
) {
  if $db_replication_mode != 'slave'
  {
    # we don't explicitly need to init the DB with sideboard anymore,
    # the empty tables will be created if they don't exist already.
    # However, I'd like to keep this section so that if we need to do any
    # initial DB init or migration, we can put it here.  -Dom

    #exec { "uber_init_db_${name}" :
    #  command     => "${venv_python} uber/init_db.py",
    #  cwd         => "${uber_path}",
    #  refreshonly => true,
    #}
  }
}
