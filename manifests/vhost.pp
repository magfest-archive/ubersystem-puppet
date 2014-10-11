define uber::vhost (
  $hostname,
  $ssl_crt_bundle,
  $ssl_crt_key,
) {
  if ! defined(Nginx::Resource::Vhost[$hostname]) {
    nginx::resource::vhost { $hostname:
      www_root         => '/var/www/',
      rewrite_to_https => true,
      ssl              => true,
      ssl_cert         => $ssl_crt_bundle,
      ssl_key          => $ssl_crt_key,
    }
  }
}
