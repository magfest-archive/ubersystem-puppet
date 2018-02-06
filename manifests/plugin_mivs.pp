# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_mivs (
  $git_repo = "https://github.com/magfest/mivs",
  $git_branch = "master",

  # INI settings below
  $mivs_round_one_deadline = undef,
  $mivs_video_response_expected = undef,
  $mivs_round_two_start = undef,
  $mivs_round_two_deadline = undef,
  $mivs_judging_deadline = undef,
  $mivs_round_two_complete = undef,
  $mivs_confirm_deadline = undef,
  $mivs_submission_grace_period = undef,
  $mivs_start_year = undef,
) {
  uber::repo { "${uber::plugins_dir}/mivs":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/mivs/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/mivs-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/mivs"] ],
  }
}
