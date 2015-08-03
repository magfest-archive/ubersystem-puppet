class uber::app
(
  $sideboard_repo = 'https://github.com/magfest/sideboard',
  $sideboard_branch = 'master',
  $sideboard_plugins = {},
) {
  require uber::install

  uber::plugins { "plugins_${name}":
    sideboard_repo =>     $sideboard_repo,
    sideboard_branch =>   $sideboard_branch,
    sideboard_plugins =>  $sideboard_plugins,
  }

  contain uber::python_setup
  contain uber::config
}

