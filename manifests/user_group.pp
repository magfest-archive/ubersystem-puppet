class uber::user_group (
  $user = hiera('uber::user'),
  $group = hiera('uber::group'),
){
  if ! defined(Group[$group]) {
    group { $group:
     ensure => present,
   }
  }

  if ! defined(User[$user]) {
    user { $user:
     ensure     => 'present',
     groups     => [$group],
     home       => "/home/${user}",
     managehome => true,
     shell      => '/bin/bash',
     require    => Group[$group],
   }
  }

  Class["uber::app"] ~> Class["uber::user_group"]
}
