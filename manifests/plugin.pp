# install a sideboard plugin

define uber::plugin
(
  $plugins_dir,
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  # TODO: add config files in here

  uber::repo { "${plugins_dir}/${name}":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::uber_path}/plugins/"],
  }
}