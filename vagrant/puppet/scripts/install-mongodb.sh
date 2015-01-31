sed -i 's/bind_ip = 127.0.0.1$/bind_ip = 127.0.0.1,192.168.250.52/g' /etc/mongod.conf

service mongod restart

echo "
use admin
db.createUser(
  {
    user: 'siteUserAdmin',
    pwd: '0M9Ng20MeD35y8x',
    roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]
  }
)

use api_dev
db.createUser(
  {
    user: 'api_dev',
    pwd: 'LA4PnhPQR7O4vLT',
    roles: [
      { role: 'readWrite', db: 'api_dev' }
    ]
  }
)

use api_prod
db.createUser(
  {
    user: 'api_prod',
    pwd: 'i3r2t49Gn4s7wkt',
    roles: [
      { role: 'readWrite', db: 'api_prod' }
    ]
  }
)

use api_test
db.createUser(
  {
    user: 'api_test',
    pwd: 's3Do233O19775jt',
    roles: [
      { role: 'readWrite', db: 'api_test' }
    ]
  }
)" | mongo
