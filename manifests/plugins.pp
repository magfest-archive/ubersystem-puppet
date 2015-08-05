import 'plugin.pp'

class uber::plugins
(
  $sideboard_repo,
  $sideboard_branch,
  $sideboard_plugins,
  $extra_plugins = undef,
  $debug_skip = false,
) {
  if $debug_skip == false {

    $plugin_defaults = {
      'user'        => $uber::user,
      'group'       => $uber::group,
      'plugins_dir' => "${uber::uber_path}/plugins",
    }

    # sideboard
    uber::repo { $uber::uber_path:
      source   => $sideboard_repo,
      revision => $sideboard_branch,
      notify   => File["${uber::uber_path}/plugins/"],
    }

    file { [ "${uber::uber_path}/plugins/" ]:
      ensure => "directory",
    }

    create_resources(uber::plugin, $sideboard_plugins, $plugin_defaults)
    if $extra_plugins {
      create_resources(uber::plugin, $extra_plugins, $plugin_defaults)
    }
  }
}