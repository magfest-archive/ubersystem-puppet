class uber::python_setup
()
{
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {

    exec { "uber_install_virtualenv_${name}":
      command => "pip3 install -I virtualenv",
      cwd     => $uber::uber_path,
      path    => '/usr/bin',
      creates => "/usr/local/bin/virtualenv",
    }

    # seems puppet's virtualenv support is broken for python3, so roll our own
    exec { "uber_create_virtualenv_${name}":
      command => "virtualenv --always-copy ${uber::venv_path}",
      cwd     => $uber::uber_path,
      path    => '/usr/local/bin',
      # test -e = file exist, test -d = dir exists
      unless => "/bin/bash -c 'test -e ${uber::venv_python} && \
                  test -e ${uber::venv_pip3} && \
                  test -d ${uber::venv_path} && \
                  test -d ${uber::venv_bin}'",
      require => Exec["uber_install_virtualenv_${name}"],
    }

    file { "${uber::venv_bin}":
      mode => 775,
      recurse => true,
      require => Exec[ "uber_create_virtualenv_${name}"],
    }

    exec { "uber_install_paver_${name}":
      command => "${uber::venv_pip3} install -I paver",
      cwd     => "${uber::uber_path}",
      creates => "${uber::venv_paver}",
      require => File["${uber::venv_bin}"],
    }
  }
}
