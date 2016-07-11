# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin

class uber::plugin_magfest (
  $git_repo = "https://github.com/magfest/magfest",
  $git_branch = "master",

  # INI settings below
  $treasury_dept_checklist_form_url = '',
  $techops_dept_checklist_form_url = '',
) {
  uber::repo { "${uber::plugins_dir}/magfest":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/magfest/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/magfest-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/magfest"] ],
  }
}
