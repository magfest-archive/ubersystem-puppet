# delete this file don't check it in

class uber::test (
  $foo = "bar",
) {
  file { "/tmp/x-${foo}":
    ensure  => present,
  }
}