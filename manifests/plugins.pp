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
  }
}