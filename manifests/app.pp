class uber::app
{
  require uber::install

  contain uber::python_setup
  contain uber::plugins
  contain uber::config
}

