# barcode-specific functionality.
# TODO: probably should move this file into its own puppet module
# TODO: need to make config handling more generic, this should work with ANY plugin, and not be barcode-specific

class uber::plugin_barcode (
  $git_repo = "https://github.com/rams/barcode",
  $git_branch = "master",
) {
  uber::repo { "${uber::plugins_dir}/barcode":
    source   => $git_repo,
    revision => $git_branch,
    require  => File["${uber::plugins_dir}"],
  }

  file { "${uber::plugins_dir}/barcode/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/barcode-development.ini.erb'),
    require => [ Uber::Repo["${uber::plugins_dir}/barcode"] ],
  }
}