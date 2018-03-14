class uber::rabbitmq (
    $user = 'celery',
    $pass = 'celery',
    $host = 'localhost',
    $port = 5672,
    $vhost = 'uber',
    $queue = 'celery',
) {

    class { '::rabbitmq':
      port              => $port,
      delete_guest_user => true,
      service_ensure    => 'running',
    } ->

    rabbitmq_user { "${user}":
      admin    => true,
      password => $pass,
    } ->

    rabbitmq_vhost { "${vhost}":
      ensure => present,
    } ->

    rabbitmq_user_permissions { "${user}@${vhost}":
      configure_permission => '.*',
      read_permission      => '.*',
      write_permission     => '.*',
    } ->

    rabbitmq_queue { "${queue}@${vhost}":
      user     => $user,
      password => $pass,
    }
}
