# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_magstock (
  $git_repo = "https://github.com/magfest/magstock",
  $git_branch = "master",

  # INI settings below
  $food_price = undef,
  $food_stock = undef,
  $campsites = undef,
  $noise_levels = undef,
  $shirt_colors = undef,
  $site_types = undef,
  $camping_types = undef,
  $coming_as_types = undef,
) {
  uber::repo { "${uber::plugins_dir}/magstock":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/magstock/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/magstock-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/magstock"] ],
  }
}