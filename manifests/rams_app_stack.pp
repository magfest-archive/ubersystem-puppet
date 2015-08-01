
class uber::rams_app_stack (

) {
  #include ::uber::app
  #include ::uber::db
  #include ::uber::nginx

  include ::uber::test
}