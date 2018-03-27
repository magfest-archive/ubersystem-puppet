class uber::redis (
    $pass = 'uber',
    $host = 'localhost',
    $port = 6379,
) {

    class { '::redis':
      bind        => $host,
      port        => $port,
      requirepass => $pass,
    }
}
