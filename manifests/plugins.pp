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
      backup  => "/tmp/barcode",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_reports':
      ensure  => absent,
      path    => "${uber::plugins_dir}/reports",
      backup  => "/tmp/reports",
      recurse => true,
      purge   => true,
      force   => true,
    }

    # file {'remove_uber_analytics':
    #   ensure  => absent,
    #   path    => "${uber::plugins_dir}/uber_analytics",
    #   backup  => "/tmp/uber_analytics",
    #   recurse => true,
    #   purge   => true,
    #   force   => true,
    # }

    file {'remove_hotel':
      ensure  => absent,
      path    => "${uber::plugins_dir}/hotel",
      backup  => "/tmp/hotel",
      recurse => true,
      purge   => true,
      force   => true,
    }

    file {'remove_attendee_tournaments':
      ensure  => absent,
      path    => "${uber::plugins_dir}/attendee_tournaments",
      backup  => "/tmp/attendee_tournaments",
      recurse => true,
      purge   => true,
      force   => true,
    }

    # file {'remove_mivs':
    #   ensure  => absent,
    #   path    => "${uber::plugins_dir}/mivs",
    #   backup  => "/tmp/mivs",
    #   recurse => true,
    #   purge   => true,
    #   force   => true,
    # }

    # file {'remove_mits':
    #   ensure  => absent,
    #   path    => "${uber::plugins_dir}/mits",
    #   backup  => "/tmp/mits",
    #   recurse => true,
    #   purge   => true,
    #   force   => true,
    # }

    file {'remove_magfest':
      ensure  => absent,
      path    => "${uber::plugins_dir}/magfest",
      backup  => "/tmp/magfest",
      recurse => true,
      purge   => true,
      force   => true,
    }
}
