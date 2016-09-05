# helper profile that includes all stuff needed to setup a fully-functional

class uber::profile_rams_full_stack (

) {
  require ::uber::firewall
  require ::uber::permissions
  require ::uber::db
  require ::uber::app
  require ::uber::nginx
  require ::uber::daemon
  require ::uber::log-filebeat

  # workaround puppet waiting to apply 'ufw enable' til later on in the process
  # if this gives you errors later, disable it, or move ::uber::firewall to happen last in the sequence above
  Exec['ufw-enable'] -> Class['uber::app']
}