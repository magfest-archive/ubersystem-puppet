# doesn't work right now.
define uber::create_index_html (
  $public_url,
  $event_name,
  $year,
) {
  if ! defined(Concat['/var/www/index.html']) {
    concat { '/var/www/index.html':
      ensure => present,
    }
  }

  concat::fragment { "uberindexfilehtml_header_${name}":
    target  => '/var/www/index.html',
    content => "<html><body><h1>Ubersystem</h1><br/>",
    order   => '01',
  }

  concat::fragment { "uberindexfilehtml_footer_${name}":
    target  => '/var/www/index.html',
    content => "</body></html>",
    order   => '03',
  }

  concat::fragment { "uberindexfilehtml_${name}":
    target  => '/var/www/index.html',
    content => "<p><a href=\"${public_url}\">${event_name} ${year} Ubersystem</a></p>",
    order   => '02',
  }
}
