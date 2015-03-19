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
  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    service_enabled         => true,
    
    users                   => {
      'api_dev@localhost'   => {
        ensure              => 'present',
	password_hash       => '*95DFC9EE8EAE5330D7892E32CC8B76648790916C'
        # password = LA4PnhPQR7O4vLT
      },
      'api_prod@localhost'   => {
        ensure               => 'present',
        password_hash        => '*4DCA60DCA667F5879D877080317C213FA42A40F8'
        # password = i3r2t49Gn4s7wkt
      },
      'api_test@localhost'   => {
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
      'api_dev@localhost/api_dev.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_dev.*',
	user => 'api_dev@localhost'
      },
      'api_prod@localhost/api_prod.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_prod.*',
	user => 'api_prod@localhost'
      },
      'api_test@localhost/api_test.*' => {
        ensure => 'present',
	options => ['GRANT'],
	privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
	table => 'api_test.*',
	user => 'api_test@localhost'
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
