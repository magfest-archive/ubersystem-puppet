# Uses filebeat to ship our logs out to a centralized Elastisearch server

class uber::log-filebeat (
  $server_name_and_port = '',
  $daemon_name = hiera("uber::daemon_name"),
  $app_logfile_name = hiera("uber::app_logfile_name"),
  $celery_worker_logfile = hiera("uber::celery_worker_logfile"),
  $celery_beat_logfile = hiera("uber::celery_beat_logfile"),
) {
  if ($server_name_and_port) {
    class { 'filebeat':
      outputs => {
        'elasticsearch' => {
          'hosts'       => [
            $server_name_and_port
          ],
          'index'       => 'filebeat'
        },
        logging         => {
          'to_syslog' => false,
          'to_files'  => true,
        },
      },
    }

    $multiline = {
      pattern => '^[[:space:]]',
      negate => false,
      match => 'after',
    }

    $exclude_files = ['.gz$']

    filebeat::prospector { 'syslogs':
      paths         => [
        '/var/log/syslog',
        '/var/log/auth.log',
      ],
      doc_type      => 'log',
      exclude_files => $exclude_files,
      fields        => {
        'log_source' => 'system',
      },
    }

    filebeat::prospector { 'nginxlogs':
      paths         => [
        '/var/log/nginx/*.log',
      ],
      doc_type      => 'log',
      exclude_files => $exclude_files,
      fields        => {
        'log_source' => 'nginx',
      },
    }

    filebeat::prospector { 'rabbitmqlogs':
      paths         => [
        '/var/log/rabbitmq/*.log',
      ],
      doc_type      => 'log',
      exclude_files => $exclude_files,
      fields        => {
        'log_source' => 'rabbitmq',
      },
    }

    filebeat::prospector { 'applogs':
      paths         => [
        '/var/log/supervisor/*',
        "${app_logfile_name}"
      ],
      doc_type      => 'log',
      exclude_files => $exclude_files,
      fields        => {
        'log_source' => 'app',
      },
      multiline => $multiline,
    }

    filebeat::prospector { 'celerylogs':
      paths         => [
        "${celery_worker_logfile}",
        "${celery_beat_logfile}"
      ],
      doc_type      => 'log',
      exclude_files => $exclude_files,
      fields        => {
        'log_source' => 'celery',
      },
      multiline => $multiline,
    }
  }
}
