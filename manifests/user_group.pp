class uber::user_group (
  $user = hiera('uber::user'),
  $group = hiera('uber::group'),
){
  group { $group:
   ensure => present,
  }

  user { $user:
   ensure     => 'present',
   groups     => [$group],
   home       => "/home/${user}",
   managehome => true,
   shell      => '/bin/bash',
   require    => Group[$group],
  }

  Class['uber::user_group'] -> Class['uber::app']
}
