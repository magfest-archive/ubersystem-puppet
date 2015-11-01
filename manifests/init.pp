class uber {
  $python_ver = '3'

  $uber_path = hiera('uber::path')

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"

  $venv_paver = "${venv_bin}/paver"
  $venv_pip3 = "${venv_bin}/pip3"

  $user = hiera('uber::user')
  $group = hiera('uber::group')

  # TODO: don't hardcode 'python 3.4' in here, figure out how to generate "3.4" instead
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  # note: on vagrant, currently, FQDN doesn't resolve if there is no domain set.
  # this is because the 'domain' fact returns "".
  # if $fqdn is available, use it, if not, use $::hostname which on vagrant = "localhost"
  #
  # I think this is the exact same behavior as $fqdn in later versions of facter.
  # (current version we're using is facter 1.7.5, which is pretty old shipped with Ubuntu)
  if $::fqdn != "" {
    $hostname = $::fqdn
  } else {
    $hostname = $::hostname
  }

  $plugins_dir = "${uber_path}/plugins"
  $priority_plugins = hiera('uber::priority_plugins', 'uber,')
  $plugin_defaults = {
    'user'        => $user,
    'group'       => $group,
  }
}
