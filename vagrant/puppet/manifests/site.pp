node 'api' {
  class { 'nodejs':
    version => 'v0.10.36',
  }

  package { 'eslint':
    provider => 'npm',
    require => Class['nodejs']
  }
  
  class { 'nginx':
  }
  nginx::resource::vhost { 'api.peeracle.local':
    proxy => 'http://localhost:8080'
  }
}

node 'client' {
  class { 'nginx':
  }
  nginx::resource::vhost { 'client.peeracle.local':
    ensure => present,
    www_root => '/home/vagrant/client/app',
    access_log => '/home/vagrant/client/nginx_access.log',
    error_log => '/home/vagrant/client/nginx_error.log',
  }
}

node 'db' {  
  class {'::mongodb::server':
    auth => true,
    verbose => true,
    bind_ip => ['127.0.0.1', '192.168.250.52']
  }
  
  mongodb::db { 'api_dev':
    tries    => 10,
    user     => 'api_dev',
    password => 'LA4PnhPQR7O4vLT',
    require  => Class['mongodb::server'],
  }

  mongodb::db { 'api_prod':
    tries    => 10,
    user     => 'api_prod',
    password => 'i3r2t49Gn4s7wkt',
    require  => Class['mongodb::server'],
  }

  mongodb::db { 'api_test':
    tries    => 10,
    user     => 'api_test',
    password => 's3Do233O19775jt',
    require  => Class['mongodb::server'],
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