# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_bands (
  $git_repo = "https://github.com/magfest/bands",
  $git_branch = "master",
  $band_panel_deadline = undef,
  $band_bio_deadline = undef,
  $band_agreement_deadline = undef,
  $band_w9_deadline = undef,
  $band_merch_deadline = undef,
  $band_charity_deadline = undef,
  $band_badge_deadline = undef,
  $stage_agreement_deadline = undef,
  $stage_agreement_deadline = undef,
) {
  uber::repo { "${uber::plugins_dir}/bands":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/bands/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/bands-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/bands"] ],
  }
}
