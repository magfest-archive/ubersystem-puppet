class uber::python {
  class { '::python':
    # ensure   => present,
    version    => $uber::python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }
}

define uber::python_setup
(
  $venv_path,
  $venv_bin,
  $venv_python,
  $uber_path,
  $debug_skip = false,
) {
  if $debug_skip == false {
    $venv_paver = "${venv_bin}/paver"
    $venv_pip3 = "${venv_bin}/pip3"

    # TODO: don't hardcode 'python 3.4' in here, set it up in ::uber
    $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

    exec { "uber_install_virtualenv_${name}":
      command => "pip3 install virtualenv",
      cwd     => $uber_path,
      path    => '/usr/bin',
      creates => "${venv_path}",
      notify  => Exec[ "uber_virtualenv_${name}" ],
    }

    # seems puppet's virtualenv support is broken for python3, so roll our own
    exec { "uber_virtualenv_${name}":
      command => "virtualenv-3.4 --always-copy ${venv_path}",
      cwd     => $uber_path,
      path    => '/usr/local/bin',
      creates => "${venv_path}",
      notify  => Exec[ "uber_install_paver_${name}" ],
    }

    exec { "uber_install_paver_${name}":
      command => "${venv_pip3} install paver",
      cwd     => "${uber_path}",
      notify  => Exec[ "setup_perms_venv_$name" ],
    }

    # setup permissions for the env/bin directory (on vagrant, these are affected by weird folder sharing settings)
    # this solves the problem of env/bin/python not being set as executable
    $venv_mode = 'a+x'
    exec { "setup_perms_venv_$name":
      command => "/bin/chmod -R ${venv_mode} ${venv_bin}",
      timeout => 3600, # this can take a while on vagrant, set it high
      notify  => Exec["uber_paver_${name}"],
    }

    exec { "uber_paver_${name}":
      command => "${venv_paver} install_deps",
      cwd     => "${uber_path}",
      # creates => "TODO",
      timeout => 3600, # this can take a while on vagrant, set it high
    }
  }
}
