class uber::install {

  # TODO install UTF lcoale stuff from Eli's Vagrant script

  if defined(Package['git']) == false {
    package { 'git': 
      ensure => present 
    }
  }

  if defined(Package['postgresql']) == false {
    package { 'postgresql':
      ensure => present,
    }
  }

  if defined(Package['postgresql-contrib']) == false {
    package { 'postgresql-contrib':
      ensure => present,
    }
  }

  if defined(Package['libpq-dev']) == false {
    package { 'libpq-dev':
      ensure => present,
    }
  }

  if defined(Package['python3-pip']) == false {
    package { 'python3-pip':
      ensure => present,
    }
  }
  
  if defined(Package['python3-tk']) == false {
    package { 'python3-tk':
      ensure => present,
    }
  }

  class { '::python':
    # ensure   => present,
    version    => $uber::python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }
}
