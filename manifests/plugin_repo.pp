define uber::plugin_repo (
  $user,
  $group,
  $git_repo,
  $git_branch,
) {
  # $name is the path to install the plugin to
  vcsrepo { $name:
    ensure   => latest,
    owner    => $user,
    group    => $group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch
  }
}
