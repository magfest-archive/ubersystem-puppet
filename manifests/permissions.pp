class uber::permissions
(
  $user = hiera('uber::user'),
  $group = hiera('uber::group')
)
{
  require uber::user_group
  require uber::app

  # setup owner
  exec { "setup_owner_$name":
    command => "/bin/chown -R ${user}:${group} ${uber::uber_path}",
    refreshonly => true,
  }

  # setup permissions
  $mode = 'o-rwx,g-w,u+rw'
  exec { "setup_perms_$name":
    command => "/bin/chmod -R $mode ${uber::uber_path}",
    refreshonly => true,
  }

  Class['uber::user_group'] ~> Class['uber::permissions']
  Class['uber::app'] ~> Class['uber::permissions']
}