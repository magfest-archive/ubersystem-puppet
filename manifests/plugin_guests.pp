# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_guests (
  $git_repo = "https://github.com/magfest/guests",
  $git_branch = "master",

  # INI settings below
  $band_email = undef,
  $band_email_signature = undef,
  $require_dedicated_guest_table_presence = true,

  $guest_merch_enums = undef,

  $auction_start = '',
  $band_panel_deadline = '',
  $band_bio_deadline = '',
  $band_info_deadline = '',
  $band_taxes_deadline = '',
  $band_merch_deadline = '',
  $band_charity_deadline = '',
  $band_badges_deadline = '',
  $band_stage_plot_deadline = '',
  $guest_panel_deadline = '',
  $guest_bio_deadline = '',
  $guest_info_deadline = '',
  $guest_taxes_deadline = '',
  $guest_merch_deadline = '',
  $guest_charity_deadline = '',
  $guest_badges_deadline = '',
  $guest_autograph_deadline = '',
  $guest_interview_deadline = '',
  $guest_travel_plans_deadline = '',
) {
  uber::repo { "${uber::plugins_dir}/guests":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/guests/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/guests-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/guests"] ],
  }
}
