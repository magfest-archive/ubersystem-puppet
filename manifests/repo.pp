define uber::repo
(
  $source,
  $ensure = latest,
  $owner = $uber::user,
  $group = $uber::group,
  $revision = 'master',
)
{
  include uber::install_dependencies

  vcsrepo { $name:
    ensure   => latest,
    owner    => $owner,
    group    => $group,
    provider => git,
    source   => $source,
    revision => $revision,
    notify   => Class["uber::install_dependencies"],
  }
}