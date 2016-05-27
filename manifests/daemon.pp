class uber::daemon (
  $user = hiera("uber::user"),
  $group = hiera("uber::group")
) {
  require uber::app

  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    supervisor::program { 'uber_daemon' :
      ensure        => present,
      enable        => true,
      command       => "${uber::venv_python} sideboard/run_server.py",
      directory     => $uber::uber_path,
      user          => $user,
      group         => $group,
      logdir_mode   => '0770',
    }

    Class["uber::app"] ~> Service["supervisor::uber_daemon"]
  }
}
