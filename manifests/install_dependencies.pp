class uber::install_dependencies ()
{
  require uber::python_setup

  # only needs to happen if source control is updated

  exec { "uber_install_deps_${name}":
    command => "${uber::venv_paver} install_deps",
    cwd     => "${uber::uber_path}",
    refreshonly => true,
    timeout => 3600, # this can take a while on vagrant, set it high
  }
}