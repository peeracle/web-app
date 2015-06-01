exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

node 'api' {
  file { '/home/vagrant/api/logs':
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant'
  }
  
  class { 'nodejs': }

  package { 'nodemon':
    provider => 'npm',
    ensure => present,
    require => Class['nodejs']
  }
  
  package { 'eslint':
    provider => 'npm',
    ensure => present,
    require => Class['nodejs']
  }
  
  class { 'nginx': }
  
  nginx::resource::vhost { 'api.peeracle.local':
    proxy => 'http://localhost:8080',
    access_log => '/home/vagrant/api/logs/nginx_access.log',
    error_log => '/home/vagrant/api/logs/nginx_error.log',
  }
}

node 'client' {  
  file { '/home/vagrant/client/logs':
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant'
  }
  
  class { 'nginx': }
  
  nginx::resource::vhost { 'client.peeracle.local':
    ensure => present,
    www_root => '/home/vagrant/client/app',
    access_log => '/home/vagrant/client/logs/nginx_access.log',
    error_log => '/home/vagrant/client/logs/nginx_error.log',
  }

  class { 'nodejs': }

  package { 'bower':
    provider => 'npm',
    ensure => present,
    require => Class['nodejs']
  }
  
  package { 'grunt-cli':
    provider => 'npm',
    ensure => present,
    require => Class['nodejs']
  }
}

node 'db' {

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '*',
    postgres_password          => 'TPSrep0rt?',
  }

  postgresql::server::db { 'api_dev':
    user     => 'api_dev',
    password => postgresql_password('api_dev', 'LA4PnhPQR7O4vLT'),
  }

  postgresql::server::role { 'marmot':
    password_hash => postgresql_password('marmot', 'mypasswd'),
  }

  postgresql::server::database_grant { 'test1':
    privilege => 'ALL',
    db        => 'api_dev',
    role      => 'marmot',
  }

  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    override_options        => {
      'mysqld' => {
        'bind-address' => '0.0.0.0',
      }
    },
    service_enabled         => true,
    users                   => {
      'api_dev@192.168.250.1'   => {
        ensure              => 'present',
	password_hash       => '*95DFC9EE8EAE5330D7892E32CC8B76648790916C'
        # password = LA4PnhPQR7O4vLT
      },
      'api_prod@192.168.250.1'   => {
        ensure               => 'present',
        password_hash        => '*4DCA60DCA667F5879D877080317C213FA42A40F8'
        # password = i3r2t49Gn4s7wkt
      },
      'api_test@192.168.250.1'   => {
        ensure               => 'present',
	password_hash        => '*DDAEFB47FB359FFDDB397D7D2F56EA6DBC4BC763'
        # password = s3Do233O19775jt
      }
    },

    databases => {
      'api_dev' => {
        ensure  => 'present',
        charset => 'utf8',
      },
      'api_prod' => {
        ensure  => 'present',
        charset => 'utf8',
      },
      'api_test' => {
        ensure  => 'present',
        charset => 'utf8',
      }
    },

    grants => {
      'api_dev@192.168.250.1/api_dev.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['ALTER', 'CREATE', 'DROP', 'SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_dev.*',
	user => 'api_dev@192.168.250.1'
      },
      'api_prod@192.168.250.1/api_prod.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['ALTER', 'CREATE', 'DROP', 'SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_prod.*',
	user => 'api_prod@192.168.250.1'
      },
      'api_test@192.168.250.1/api_test.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['ALTER', 'CREATE', 'DROP', 'SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_test.*',
	user => 'api_test@192.168.250.1'
      }
    }
  }
}

node 'redis' {
  class { 'redis':
    version => '2.8.19'
  }
}

node 'mq' {  
  class { '::rabbitmq':
    service_manage    => false,
    port              => '5672',
    delete_guest_user => true
  }
}
