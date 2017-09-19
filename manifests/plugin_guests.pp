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
) {

  # The following two "file" definitions rename an existing "bands" plugin
  # directory to "guests". This will absolutely break if we ever create
  # another plugin named "bands".

  file { "${uber::plugins_dir}/guests":
    ensure  => 'directory',
    source  => "file://${uber::plugins_dir}/bands",
    recurse => true,
    before  => File["${uber::plugins_dir}/bands"],
  }

  file { "${uber::plugins_dir}/bands":
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
  }

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
