# helper profile that includes all stuff needed to setup a fully-functional

class uber::profile_rams_full_stack (

) {
  include ::uber::user_group
  include ::uber::app
  include ::uber::db
  include ::uber::nginx
  include ::uber::daemon
  include ::uber::firewall
  include ::uber::permissions
}