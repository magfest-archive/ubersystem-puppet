define uber::repo
(
  $source,
  $ensure = latest,
  $owner = $uber::user,
  $group = $uber::group,
  $revision = 'master',
)
{
  if !hiera('debugONLY_dont_init_python_or_git_repos_or_plugins') {
    include uber::install_dependencies
    include uber::python_setup

    vcsrepo { $name:
      ensure   => latest,
      owner    => $owner,
      group    => $group,
      provider => git,
      source   => $source,
      revision => $revision,
      notify   => [ Class["uber::python_setup"], Class["uber::install_dependencies"] ]
    }
  }
}
