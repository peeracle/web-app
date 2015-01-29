node 'api' {
  class { 'nodejs':
    version => 'v0.10.36',
  }
  
  package { 'forever':
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs']
  }
  
  class { 'nginx':
  }
  nginx::resource::vhost { 'api.peeracle.local':
    proxy => 'http://localhost:3000',
    access_log => '/home/vagrant/api/nginx_access.log',
    error_log => '/home/vagrant/api/nginx_error.log',
  }
}

node 'client' {
  class { 'nginx':
  }
  nginx::resource::vhost { 'client.peeracle.local':
    ensure => present,
    www_root => '/home/vagrant/client',
    access_log => '/home/vagrant/client/nginx_access.log',
    error_log => '/home/vagrant/client/nginx_error.log',
  }
}

node 'db' {
  class {'::mongodb::server':
    port    => 27018,
    verbose => true,
  }
}

node 'redis' {
  class { 'redis':
    version => '2.8.19',
  }
}

node 'mq' {
  class { '::rabbitmq':
    service_manage    => false,
    port              => '5672',
    delete_guest_user => true,
  }
}