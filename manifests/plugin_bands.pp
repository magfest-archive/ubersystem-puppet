# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_bands (
  $git_repo = "https://github.com/magfest/bands",
  $git_branch = "master",

  # INI settings below
  $auction_start = "2016-02-21 11",
  $band_panel_deadline = "2015-12-20",
  $band_bio_deadline = "2016-01-03",
  $band_agreement_deadline = "2016-01-17",
  $band_w9_deadline = "2016-01-17",
  $band_merch_deadline = "2016-01-31",
  $band_charity_deadline = "2016-01-31",
  $band_badge_deadline = "2016-02-07",
  $stage_agreement_deadline = "2016-02-07",
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
