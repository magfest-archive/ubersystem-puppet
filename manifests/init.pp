class uber {
  $python_ver = '3'

  $uber_path = hiera('uber::path')

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"

  $venv_paver = "${venv_bin}/paver"
  $venv_pip3 = "${venv_bin}/pip3"

  # TODO: don't hardcode 'python 3.4' in here, figure out how to get at that data
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  class {'uber::install': } -> Class['uber']
}