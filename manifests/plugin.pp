# sideboard can install a bunch of plugins which each pull their own
# git repos
define uber::plugin (
  $plugins_dir,
  $user,
  $group,
  $git_repo,
  $git_branch,
) {
  uber::plugin_repo { "${plugins_dir}/${name}":
    user       => $user,
    group      => $group,
    git_repo   => $git_repo,
    git_branch => $git_branch,
  }
}
