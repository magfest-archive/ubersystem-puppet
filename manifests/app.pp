class uber::app
{
  require uber::install

  contain uber::plugins
  contain uber::python_setup
  contain uber::config
}

