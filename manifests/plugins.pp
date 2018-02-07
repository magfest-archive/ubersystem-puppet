import 'plugin.pp'

class uber::plugins
(
  $sideboard_repo,
  $sideboard_branch,
  $sideboard_plugins,
  $extra_plugins = undef,
) {
    # sideboard
    uber::repo { $uber::uber_path:
      source   => $sideboard_repo,
      revision => $sideboard_branch,
      notify   => File["${uber::plugins_dir}"],
    }

    file { [ "${uber::plugins_dir}" ]:
      ensure => "directory",
    }

    create_resources(uber::plugin, $sideboard_plugins, $uber::plugin_defaults)
    if $extra_plugins {
      create_resources(uber::plugin, $extra_plugins, $uber::plugin_defaults)
    }

    # ===========================================
    # plugins that have been merged into uber
    # ===========================================

    file {'remove_barcode':
      ensure  => absent,
      path    => "${uber::plugins_dir}/barcode",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_reports':
      ensure  => absent,
      path    => "${uber::plugins_dir}/reports",
      recurse => true,
      purge   => true,
      force   => true,
    }

    $uber_analytics_source = file("${uber::plugins_dir}/uber_analytics/uber_analytics/static/analytics/extra-attendance-data.json", '/dev/null')
    if($uber_analytics_source != '') {
      file { 'copy_uber_analytics':
        ensure  => 'present',
        path    => "${uber::plugins_dir}/uber/uber/static/analytics/extra-attendance-data.json",
        source  => "${uber::plugins_dir}/uber_analytics/uber_analytics/static/analytics/extra-attendance-data.json",
        before  => File['remove_uber_analytics'],
      }
    }

    file {'remove_uber_analytics':
      ensure  => absent,
      path    => "${uber::plugins_dir}/uber_analytics",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_hotel':
      ensure  => absent,
      path    => "${uber::plugins_dir}/hotel",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_attendee_tournaments':
      ensure  => absent,
      path    => "${uber::plugins_dir}/attendee_tournaments",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file { "${uber::plugins_dir}/uber/uploaded_files":
      ensure  => 'directory',
    }

    file { 'copy_mivs_game_images':
      ensure  => 'directory',
      recurse => true,
      source  => ["${uber::plugins_dir}/mivs/uploaded_files/mivs_game_images", "${uber::plugins_dir}/mivs/screenshots"],
      sourceselect => 'all',
      path    => "${uber::plugins_dir}/uber/uploaded_files/mivs_game_images",
      before  => File['remove_mivs'],
    }

    file {'remove_mivs':
      ensure  => absent,
      path    => "${uber::plugins_dir}/mivs",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file { 'copy_mits_game_images':
      ensure  => 'directory',
      recurse => true,
      source  => ["${uber::plugins_dir}/mits/pictures"],
      sourceselect => 'all',
      path    => "${uber::plugins_dir}/uber/uploaded_files/mits_game_images",
      before  => File['remove_mits'],
    }

    file {'remove_mits':
      ensure  => absent,
      path    => "${uber::plugins_dir}/mits",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_magfest':
      ensure  => absent,
      path    => "${uber::plugins_dir}/magfest",
      recurse => true,
      purge   => true,
      force   => true,
    }
}
