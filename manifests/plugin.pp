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

  vcsrepo { "${plugins_dir}/${name}":
    ensure   => latest,
    owner    => $user,
    group    => $group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch
  }
}