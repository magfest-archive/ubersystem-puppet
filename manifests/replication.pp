# Class uber::db-replication
#
# Handles replication stuff for ubersystem
#
#

define uber::replication (
  # DB replication common settings
  $db_name,
  $db_replication_mode, # none, master, or slave
  $db_replication_user,
  $db_replication_password,

  # DB replication slave settings ONLY
  $db_replication_master_ip, # IP of the master server
  $uber_db_util_path,

  # DB replication master settings ONLY
  $slave_ips,
) {
  # setup replication
  if $db_replication_mode == 'master'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    uber::dbreplicationmaster { "${db_name}_replication_master":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      slave_ips            => $slave_ips,
    }
  }
  if $db_replication_mode == 'slave'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    if $db_replication_master_ip == '' {
      fail("can't do DB slave replication without a master IP address")
    }

    uber::db-replication-slave { "${db_name}_replication_slave":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      master_ip            => $db_replication_master_ip,
      uber_db_util_path    => $uber_db_util_path,
    }
  }
}
