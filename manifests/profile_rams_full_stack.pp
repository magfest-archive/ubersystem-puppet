# helper profile that includes all stuff needed to setup a fully-functional ubersystem server

class uber::profile_rams_full_stack (

) {
  require ::uber::firewall

  # workaround puppet waiting to apply 'ufw enable' til later on in the process
  # if this gives you errors later, disable it, or move ::uber::firewall to happen last in the sequence above
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    Exec['ufw-enable'] -> Class['uber::app']
  }

  include nginx
  include rabbitmq

  require ::uber::permissions
  require ::uber::db
  require ::uber::app
  require ::uber::nginx
  require ::uber::celery_beat
  require ::uber::celery_worker
  require ::uber::daemon
  require ::uber::log-filebeat
}
