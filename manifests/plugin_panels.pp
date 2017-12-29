# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_panels (
  $git_repo = "https://github.com/magfest/panels",
  $git_branch = "master",

  # INI settings below

  $presentation_enums = undef,

  $hide_schedule = true,
  $expected_response = undef,
  $panel_rooms = undef,
  $panel_app_deadline = undef,
  $alt_schedule_url = undef,
  $attractions_email = undef,
  $panels_twilio_number = undef,
  $panels_twilio_sid = '',
  $panels_twilio_token = '',
) {
  uber::repo { "${uber::plugins_dir}/panels":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/panels/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/panels-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/panels"] ],
  }
}
