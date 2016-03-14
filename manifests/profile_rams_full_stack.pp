# helper profile that includes all stuff needed to setup a fully-functional

class uber::profile_rams_full_stack (

) {
  require ::uber::permissions
  require ::uber::app
  require ::uber::plugin_barcode
  require ::uber::plugin_panels
  require ::uber::db
  require ::uber::nginx
  require ::uber::daemon
  require ::uber::firewall
}