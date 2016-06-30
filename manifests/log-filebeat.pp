# Uses filebeat to ship our logs out to a centralized Elastisearch server

class uber::log-filebeat (
  $server_name_and_port = '',
  $daemon_name = hiera("uber::daemon_name"),
  $app_logfile_name = hiera("uber::app_logifle_name")
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
      logging => {
        'to_syslog' => false,
        'to_files' => true,
        },
      },
    }

    $exclude_files = ['.gz$']

    filebeat::prospector { 'syslogs':
      paths         => [
        '/var/log/syslog',
        '/var/log/auth.log',
      ],
      doc_type      => 'syslog-beat',
      exclude_files => $exclude_files,
    }

    filebeat::prospector { 'nginxlogs':
      paths         => [
        '/var/log/nginx/*.log',
      ],
      doc_type      => 'nginx-beat',
      exclude_files => $exclude_files,
    }

    filebeat::prospector { 'applogs':
      paths         => [
        '/var/log/supervisor/*',
        "${app_logfile_name}"
      ],
      doc_type      => 'app-beat',
      exclude_files => $exclude_files,
    }
  }
}