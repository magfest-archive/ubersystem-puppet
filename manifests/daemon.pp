class uber::daemon (
  $user = hiera("uber::user"),
  $group = hiera("uber::group"),
  $daemon_name = hiera("uber::daemon_name"),
  $app_logfile_name = hiera("uber::app_logifle_name")
) {
  require uber::app

  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    supervisor::program { $daemon_name :
      ensure        => present,
      enable        => true,
      command       => "${uber::venv_python} sideboard/run_server.py",
      directory     => $uber::uber_path,
      user          => $user,
      group         => $group,
      logdir_mode   => '0770',

      # disable supervisor's logfile rotation in favor of system's logrotate settings
      stdout_logfile_maxsize   => '0',
      stdout_logfile_backups   => 0,
      stderr_logfile_maxsize   => '0',
      stderr_logfile_backups   => 0,

      stdout_logfile => $app_logfile_name,
      stderr_logfile => "",
      redirect_stderr => true,
    }

    file { "/etc/logrotate.d/${daemon_name}":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => '0644',
      content => template('uber/logrotate.supervisor_daemon.erb'),
    }

    Class["uber::app"] ~> Service["supervisor::uber_daemon"]
  }
}
