# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_hotel (
  $git_repo = "https://github.com/magfest/hotel",
  $git_branch = "master",

  # INI settings below
  $hotel_req_hours = undef,
) {
  uber::repo { "${uber::plugins_dir}/hotel":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/hotel/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/hotel-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/hotel"] ],
  }
}
