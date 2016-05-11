# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin, and not be tabletop-specific

class uber::plugin_tabletop (
  $git_repo = "https://github.com/magfest/tabletop",
  $git_branch = "master",

  # INI settings below
  $twilio_sid = '',
  $twilio_token = '',
) {
  uber::repo { "${uber::plugins_dir}/tabletop":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/tabletop/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/tabletop-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/tabletop"] ],
  }
}
