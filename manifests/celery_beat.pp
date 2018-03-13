class uber::celery_beat (
  $user = hiera("uber::user"),
  $group = hiera("uber::group"),
  $celery_beat_name = hiera("uber::celery_beat_name"),
  $celery_beat_logfile = hiera("uber::celery_beat_logfile")
) {
  require uber::app

  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    supervisor::program { $celery_beat_name :
      ensure        => present,
      enable        => true,
      command       => "${uber::venv_celery} -A uber.tasks beat",
      directory     => $uber::uber_path,
      user          => $user,
      group         => $group,
      logdir_mode   => '0770',

      # disable supervisor's logfile rotation in favor of system's logrotate settings
      stdout_logfile_maxsize   => '0',
      stdout_logfile_backups   => 0,
      stderr_logfile_maxsize   => '0',
      stderr_logfile_backups   => 0,

      stdout_logfile => $celery_beat_logfile,
      stderr_logfile => "",
      redirect_stderr => true,
    }

    file { "/etc/logrotate.d/${celery_beat_name}":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => '0644',
      content => template('uber/logrotate.supervisor_daemon.erb'),
    }

    Class["uber::app"] ~> Service["supervisor::${celery_beat_name}"]
  }
}
