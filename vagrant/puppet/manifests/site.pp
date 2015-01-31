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
  exec {'mongodb-apt':
    command => '/bin/bash /vagrant/vagrant/puppet/scripts/mongodb-apt.sh'
  }

  exec {'mongodb-apt-install':
    command => '/bin/bash /vagrant/vagrant/puppet/scripts/mongodb-apt-install.sh',
    require => Exec['mongodb-apt']
  }

  exec {'install-mongodb':
    command => '/bin/bash /vagrant/vagrant/puppet/scripts/install-mongodb.sh',
    require => Exec['mongodb-apt-install']
  }
  
#  class {'::mongodb::server':
#    auth => true,
#    verbose => true,
#    bind_ip => ['127.0.0.1', '192.168.250.52']
#  }

#  mongodb::db { 'api_dev':
#    tries    => 10,
#    user     => 'dev',
#    password => 'LA4PnhPQR7O4vLT',
#    require  => Class['mongodb::server'],
#  }

#  mongodb::db { 'api_prod':
#    tries    => 10,
#    user     => 'prod',
#    password => 'i3r2t49Gn4s7wkt',
#    require  => Class['mongodb::server'],
#  }

#  mongodb::db { 'api_test':
#    tries    => 10,
#    user     => 'test',
#    password => 's3Do233O19775jt',
#    require  => Class['mongodb::server'],
#  }
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