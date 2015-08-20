# install a sideboard plugin

define uber::plugin
(
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  # TODO: add config files in here

  uber::repo { "${uber::plugins_dir}/${name}":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }
}