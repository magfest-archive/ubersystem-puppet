define uber::plugins
(
  $plugins,
  $plugins_dir,
  $user,
  $group,
)
{
  $plugin_defaults = {
    'user'        => $user,
    'group'       => $group,
    'plugins_dir' => $plugins_dir,
  }
  create_resources(uber::plugin, $plugins, $plugin_defaults)
}

# sideboard can install a bunch of plugins which each pull their own
# git repos
define uber::plugin 
(
  $plugins_dir,
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  uber::plugin_repo { "${plugins_dir}/${name}":
    user       => $user,
    group      => $group,
    git_repo   => $git_repo,
    git_branch => $git_branch,
  }
}

define uber::plugin_repo
(
  $user,
  $group,
  $git_repo,
  $git_branch,
)
# $name is the path to install the plugin to
{
  vcsrepo { $name:
    ensure   => latest,
    owner    => $user,
    group    => $group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch
  }
}

define uber::instance
(
  $uber_path = '/usr/local/uber',
  $sideboard_repo = 'https://github.com/magfest/sideboard',
  $sideboard_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $ssl_crt_bundle = 'puppet:///modules/uber/selfsigned-testonly.crt',
  $ssl_crt_key = 'puppet:///modules/uber/selfsigned-testonly.key',

  $sideboard_debug_enabled = false,

  $db_host = 'localhost',
  $db_port = '5432',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',
  
  $sideboard_plugins = {},

  # DB replication common mode settings
  $db_replication_mode = 'none', # none, master, or slave
  $db_replication_user = 'replicator',
  $db_replication_password = '',

  # DB replication slave settings ONLY
  $db_replication_master_ip = '', # IP of the master server
  $uber_db_util_path = '/usr/local/uberdbutil',

  # DB replication master settings ONLY
  $slave_ips = [],

  $django_debug = False,

  $socket_port = '4321',
  $socket_host = '0.0.0.0',
  $hostname = '', # defaults to hostname of the box
  $url_prefix = 'magfest',

  $open_firewall_port = false, # if using apache/nginx, you dont want this.

  # config file settings only below
  $event_name = 'MAGFest',
  $organization_name = 'MAGFest',
  $year = 1,
  $show_affiliates_and_extras = True,
  #$group_reg_available = True,
  #$group_reg_open = True,
  $send_emails = False,
  $aws_access_key = '',
  $aws_secret_key = '',
  $stripe_secret_key = '',
  $stripe_public_key = '',
  $dev_box = False,
  $collect_exact_birthdate = False,
  #$supporter_badge_type_enabled = True,
  $prereg_open,
  #$prereg_takedown,
  #$uber_takedown,
  #$epoch,
  #$eschaton,
  #$prereg_price = 45,
  #$at_door_price = 60,
  $at_the_con = False,
  $max_badge_sales = 9999999,
  $hide_schedule = True,
  $custom_badges_really_ordered = False,
) {

  $hostname_to_use = $hostname ? {
    ''      => $fqdn,
    default => $hostname,
  }

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"
  $venv_paver = "${venv_bin}/paver"

  # TODO: don't hardcode 'python 3.4' in here, set it up in ::uber
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  uber::user_group { "users and groups ${name}":
    user   => $uber_user,
    group  => $uber_group,
    notify => Uber::Db["uber_db_${name}"]
  }

  uber::db { "uber_db_${name}":
    user             => $db_user,
    pass             => $db_pass,
    dbname           => $db_name,
    db_replication_mode => $db_replication_mode,
    notify           => Exec["stop_daemon_${name}"]
  }

  exec { "stop_daemon_${name}" :
    command     => "/usr/local/bin/supervisorctl stop ${name}",
    notify   => [ Class['uber::install'], Vcsrepo[$uber_path] ]
  }

  # sideboard
  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $sideboard_repo,
    revision => $sideboard_branch,
    notify  => File["${uber_path}/plugins/"],
  }

  file { [ "${uber_path}/plugins/" ]:
    ensure => "directory",
    notify => Uber::Plugins["${name}_plugins"],
  }

  # TODO eventually need to add a development.ini for each plugin

  uber::plugins { "${name}_plugins":
    plugins     => $sideboard_plugins,
    plugins_dir => "${uber_path}/plugins",
    user        => $uber_user,
    group       => $uber_group,
    notify      => File["${uber_path}/development.ini"],
  }

  # sideboard's development.ini
  # note: plugins can also have their own development.ini,
  # we need to take that into account.
  file { "${uber_path}/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/sb-development.ini.erb'),
    notify  => File["${uber_path}/plugins/uber/development.ini"],
  }

  # uber's development.ini
  # TODO: this is being hardcoded here.  it should instead install
  # with the plugins stuff.  each plugin might have an INI
  file { "${uber_path}/plugins/uber/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/uber-development.ini.erb'),
    notify  => Exec["uber_virtualenv_${name}"]
  }

  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { "uber_virtualenv_${name}":
    command => "${uber::python_cmd} -m venv ${venv_path} --without-pip --copies",
    cwd     => $uber_path,
    path    => '/usr/bin',
    creates => "${venv_path}",
    notify  => Exec[ "setup_perms_venv_$name" ],
  }

  # setup permissions for the env/bin directory (on vagrant, these are affected by weird folder sharing settings)
  # this solves the problem of env/bin/python not being set as executable
  $venv_mode = 'a+x'
  exec { "setup_perms_venv_$name":
    command => "/bin/chmod -R ${venv_mode} ${venv_bin}",
    notify  => File["${uber_path}/distribute_setup.py"],
  }

  file { "${uber_path}/distribute_setup.py":
    ensure => present,
    source => "${uber_path}/plugins/uber/distribute_setup.py",
    notify  => Exec["uber_distribute_setup_${name}"],
  }

  exec { "uber_distribute_setup_${name}" :
    command => "${venv_python} distribute_setup.py",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/setuptools.pth",
    notify  => Exec["uber_setup_${name}"],
  }

  exec { "uber_setup_${name}" :
    command => "${venv_python} setup.py develop",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/sideboard.egg-link",
    notify  => Exec["uber_paver_${name}"],
  }

  exec { "uber_paver_${name}":
    command => "${venv_paver} install_deps",
    cwd     => "${uber_path}",
    # creates => "TODO",
    notify  => Uber::Init_db["${name}"],
  }

  uber::init_db { "${name}":
    venv_python         => $venv_python,
    uber_path           => $uber_path,
    db_replication_mode => $db_replication_mode,
    notify  => Exec["setup_owner_$name"],
  }

  # setup owner
  exec { "setup_owner_$name":
    command => "/bin/chown -R ${uber_user}:${uber_group} ${uber_path}",
    notify  => Exec[ "setup_perms_$name" ],
  }

  # setup permissions
  $mode = 'o-rwx,g-w,u+rw'
  exec { "setup_perms_$name":
    command => "/bin/chmod -R $mode ${uber_path}",
    #notify  => Uber::Replication["${name}_replication"],
    notify  => Uber::Daemon["${name}_daemon"],
  }

  uber::replication { "${name}_replication":
    db_name                  => $db_name,
    db_replication_mode      => $db_replication_mode,
    db_replication_user      => $db_replication_user,
    db_replication_password  => $db_replication_password,
    db_replication_master_ip => $db_replication_master_ip,
    uber_db_util_path        => $uber_db_util_path,
    slave_ips                => $slave_ips,
    #notify                  => Uber::Daemon["${name}_daemon"],
    # subscribe                => Postgresql::Server::Db["${db_name}"]
  }

  # run as a daemon with supervisor
  uber::daemon { "${name}_daemon": 
    user       => $uber_user,
    group      => $uber_group,
    python_cmd => $venv_python,
    uber_path  => $uber_path,
    notify     => Uber::Firewall["${name}_firewall"],
  }

  uber::firewall { "${name}_firewall":
    socket_port        => $socket_port,
    open_firewall_port => $open_firewall_port,
    notify             => Uber::Vhost[$name],
  }

  uber::vhost { $name:
    hostname       => $hostname_to_use,
    ssl_crt_bundle => $ssl_crt_bundle,
    ssl_crt_key    => $ssl_crt_key,
    # notify       => Nginx::Resource::Location["${hostname}-${name}"],
  }

  $proxy_url = "http://127.0.0.1:${socket_port}/${url_prefix}/"
  $public_url = "https://${hostname_to_use}/${url_prefix}/"

  nginx::resource::location { "${hostname_to_use}-${name}":
    ensure   => present,
    proxy    => $proxy_url,
    location => "/${url_prefix}/",
    vhost    => $hostname_to_use,
    ssl      => true,
    notify   => File["${nginx::params::nx_conf_dir}/conf.d/default.conf"],
  }

  # delete the default.conf to ensure that our virtualhost file gets the requests for localhost.
  # this is needed if you try and access the server in a browser but not by $hostname_to_use
  file { "${nginx::params::nx_conf_dir}/conf.d/default.conf":
    ensure => absent,
    notify => Uber::Create_index_html["${name}"],
  }

  uber::create_index_html { "${name}":
    public_url => $public_url,
    event_name => $event_name,
    year => $year,
  }
}

define uber::create_index_html (
  $public_url,
  $event_name,
  $year,
) {
  if ! defined(Uber::Concat['/var/www/index.html']) {
      concat { '/var/www/index.html':
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
  }

  concat::fragment { "uberindexfilehtml_${name}":
    target  => '/var/www/index.html',
    content => "<p><a href=\"${public_url}\">${event_name} ${year} Ubersystem</a></p>",
    order   => '02',
  }
}

define uber::init_db (
  $venv_python,
  $uber_path,
  $db_replication_mode = 'none',
) {
  if $db_replication_mode != 'slave'
  {
    # we don't explicitly need to init the DB with sideboard anymore,
    # the empty tables will be created if they don't exist already.
    # However, I'd like to keep this section so that if we need to do any
    # initial DB init or migration, we can put it here.  -Dom

    #exec { "uber_init_db_${name}" :
    #  command     => "${venv_python} uber/init_db.py",
    #  cwd         => "${uber_path}",
    #  refreshonly => true,
    #}
  }
}

define uber::replication (
  # DB replication common settings
  $db_name,
  $db_replication_mode, # none, master, or slave
  $db_replication_user,
  $db_replication_password,

  # DB replication slave settings ONLY
  $db_replication_master_ip, # IP of the master server
  $uber_db_util_path,

  # DB replication master settings ONLY
  $slave_ips,
) {
  # setup replication
  if $db_replication_mode == 'master'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    uber::dbreplicationmaster { "${db_name}_replication_master":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      slave_ips            => $slave_ips,
    }
  }
  if $db_replication_mode == 'slave'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    if $db_replication_master_ip == '' {
      fail("can't do DB slave replication without a master IP address")
    }

    uber::db-replication-slave { "${db_name}_replication_slave":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      master_ip            => $db_replication_master_ip,
      uber_db_util_path    => $uber_db_util_path,
    }
  }
}


define uber::vhost (
  $hostname,
  $ssl_crt_bundle,
  $ssl_crt_key,
) {
  if ! defined(Nginx::Resource::Vhost[$hostname]) {
    nginx::resource::vhost { $hostname:
      www_root    => '/var/www/',
      rewrite_to_https => true,
      ssl              => true,
      ssl_cert         => $ssl_crt_bundle,
      ssl_key          => $ssl_crt_key,
    }
  }
}

define uber::firewall (
  $socket_port,
  $open_firewall_port = false,
) {
  if $open_firewall_port {
    ufw::allow { $title:
      port => $socket_port,
    }
  }
}


# Class uber::db-replication
#
# Handles replication stuff for ubersystem
#
# 

define uber::allow-replication-from-ip (
  $dbname,
  $username,
) {
  postgresql::server::pg_hba_rule { "rep access for ${name}":
    description => "Open up postgresql for access from ${name}",
    type        => 'hostssl',
    database    => 'replication', #$dbname,
    user        => $username,
    address     => "${name}/32",
    auth_method => 'md5',
  }

  # open this port on the firewall for this IP
  ufw::allow { "allow postgres from $name":
    from  => "$name",
    proto => 'tcp',
    port  => 5432,
  }
}

define uber::dbreplicationmaster (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $slave_ips,
) {
  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, $replication_password),
    replication   => true,
    #notify        => Postgresql::Server::Config_Entry['wal_level'],
    subscribe      => Postgresql::Server::Db["${dbname}"]
  }

  postgresql::server::config_entry { 
     # 'listen_address':       value => "*";
     'wal_level':            value => 'hot_standby';
     'max_wal_senders':      value => '3';
     'checkpoint_segments':  value => '8';
     'wal_keep_segments':    value => '8';
  }

  uber::allow-replication-from-ip { $slave_ips:
    dbname   => $dbname,
    username => $replication_user,
  }
}

define uber::db-replication-slave (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $master_ip,
  $uber_db_util_path = '/usr/local/uberdbutil'
) {

  postgresql::server::config_entry { 
    'wal_level':            value => 'hot_standby';
    'max_wal_senders':      value => '3';
    'checkpoint_segments':  value => '8';
    'wal_keep_segments':    value => '8';
    'hot_standby':          value => 'on';
  }

  # a fuller example, including permissions and ownership
  file { "${uber_db_util_path}":
    ensure => "directory",
    owner  => "postgres",
    group  => "postgres",
    mode   => 700,
    notify  => File["${uber_db_util_path}/recovery.conf"],
  }

  file { "${uber_db_util_path}/recovery.conf":
    ensure  => present,
    owner   => "postgres",
    group   => "postgres",
    mode    => 600,
    content => template('uber/pg-recovery.conf.erb'),
    notify  => File["${uber_db_util_path}/pg-start-replication.sh"],
  }

  file { "${uber_db_util_path}/pg-start-replication.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber/pg-start-replication.sh.erb'),
    notify => File["${uber_db_util_path}/sync-to-master.sh"],
  }

  file { "${uber_db_util_path}/sync-to-master.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber/pg-sync.sh.erb'),
    # notify => File["${uber_path}/event.conf"],
  }
}
