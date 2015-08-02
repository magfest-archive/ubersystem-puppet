class uber::plugins
(
  $plugins,
  $plugins_dir,
  $user,
  $group,
)
{
  $plugin_defaults = {
    'user'        => $user,
    'group'       => $group,
    'plugins_dir' => $plugins_dir,
  }
  create_resources(uber::plugin, $plugins, $plugin_defaults)
}

# sideboard can install a bunch of plugins which each pull their own git repos
define uber::plugin
(
  $plugins_dir,
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  uber::plugin_repo { "${plugins_dir}/${name}":
    user       => $user,
    group      => $group,
    git_repo   => $git_repo,
    git_branch => $git_branch,
  }
}

define uber::plugin_repo
(
  $user,
  $group,
  $git_repo,
  $git_branch,
)
# $name is the path to install the plugin to
{
  vcsrepo { $name:
    ensure   => latest,
    owner    => $user,
    group    => $group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch
  }
}

define uber::install_plugins
(
  $uber_user,
  $uber_group,
  $sideboard_repo,
  $sideboard_branch,
  $sideboard_plugins,
  $debug_skip = false,
) {
  if $debug_skip == false {
    # sideboard
    vcsrepo { $uber::uber_path:
      ensure   => latest,
      owner    => $uber_user,
      group    => $uber_group,
      provider => git,
      source   => $sideboard_repo,
      revision => $sideboard_branch,
      notify   => File["${uber::uber_path}/plugins/"],
    }

    file { [ "${uber::uber_path}/plugins/" ]:
      ensure => "directory",
      notify => Uber::Plugins["${name}_plugins"],
    }

    # TODO eventually need to add a development.ini for each plugin

    uber::plugins { "${name}_plugins":
      plugins     => $sideboard_plugins,
      plugins_dir => "${uber::uber_path}/plugins",
      user        => $uber_user,
      group       => $uber_group,
    }
  }
}