class uber::python_setup
(
  $debug_skip = false,
) {
  require uber::plugins

  if $debug_skip == false {

    exec { "uber_install_virtualenv_${name}":
      command => "pip3 install virtualenv",
      cwd     => $uber::uber_path,
      path    => '/usr/bin',
      creates => "${uber::venv_path}",
      notify  => Exec[ "uber_virtualenv_${name}" ],
    }

    # seems puppet's virtualenv support is broken for python3, so roll our own
    exec { "uber_virtualenv_${name}":
      command => "virtualenv-3.4 --always-copy ${uber::venv_path}",
      cwd     => $uber::uber_path,
      path    => '/usr/local/bin',
      creates => "${uber::venv_path}",
      notify  => Exec[ "uber_install_paver_${name}" ],
    }

    exec { "uber_install_paver_${name}":
      command => "${uber::venv_pip3} install paver",
      cwd     => "${uber::uber_path}",
      notify  => Exec[ "setup_perms_venv_$name" ],
    }

    # setup permissions for the env/bin directory (on vagrant, these are affected by weird folder sharing settings)
    # this solves the problem of env/bin/python not being set as executable
    $venv_mode = 'a+x'
    exec { "setup_perms_venv_$name":
      command => "/bin/chmod -R ${venv_mode} ${uber::venv_bin}",
      timeout => 3600, # this can take a while on vagrant, set it high
      notify  => Exec["uber_paver_${name}"],
    }

    exec { "uber_paver_${name}":
      command => "${uber::venv_paver} install_deps",
      cwd     => "${uber::uber_path}",
      # creates => "TODO",
      timeout => 3600, # this can take a while on vagrant, set it high
    }
  }
}
