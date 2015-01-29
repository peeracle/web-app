node 'api' {
  class { 'nodejs':
    version => 'v0.10.25',
  }
  package { 'express':
    provider => 'npm',
    require  => Class['nodejs']
  }
}

node 'client' {
}

node 'db' {
}

node 'redis' {
}

node 'mq' {
}