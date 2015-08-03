class uber::plugins
(
  $sideboard_repo,
  $sideboard_branch,
  $sideboard_plugins,
  $debug_skip = false,
) {
  if $debug_skip == false {
    # sideboard
    vcsrepo { $uber::uber_path:
      ensure   => latest,
      owner    => $uber::user,
      group    => $uber::group,
      provider => git,
      source   => $sideboard_repo,
      revision => $sideboard_branch,
      notify   => File["${uber::uber_path}/plugins/"],
    }

    file { [ "${uber::uber_path}/plugins/" ]:
      ensure => "directory",
      notify => Uber::Plugins["${name}_plugins"],
    }

    $plugin_defaults = {
      'user'        => $uber::user,
      'group'       => $uber::group,
      'plugins_dir' => "${uber::uber_path}/plugins",
    }
    create_resources(uber::plugin, $sideboard_plugins, $plugin_defaults)
  }
}
