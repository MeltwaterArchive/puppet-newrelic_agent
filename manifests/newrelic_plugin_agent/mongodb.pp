# This manages the mongodb requirements for newrelic-plugin-agent
#
# === Parameters
#
# [*host*]
#   Default: localhost
#   Host where the mongodb instance is running
#
# [*port*]
#   Default: 27017
#   Port the mongodb instance is listening on
#
# [*ssl*]
#   Default: false
#   If the mongodb instance is requires SSL
#
# [*admin_username*]
#   Default: undef
#   If the mongodb instance requires an admin username
#
# [*admin_password*]
#   Default: undef
#   If the mongodb instance requires an admin password
#
# [*ssl_keyfile*]
#   Default: undef
#   Path to keyfile
#
# [*ssl_certfile*]
#   Default: undef
#   Path to certfile
#
# [*ssl_cert_reqs*]
#   Default: 0
#   0 for ssl.CERT_NONE, 1 for ssl.CERT_OPTIONAL, 2 for ssl.CERT_REQUIRED
#
# [*ssl_ca_certs*]
#   Default: undef
#   Path to cacerts file
#
# === Settings
#
# [*databases*]
#   Default: undef
#   Type: Array
#   Databases names to gather metrics
#
#   Example:
#     $databases = ['db1', 'db2']
#
define newrelic_agent::newrelic_plugin_agent::mongodb (
  $host = 'localhost',
  $port = '27017',
  $ssl = false,
  $admin_username = undef,
  $admin_password = undef,
  $ssl_keyfile = undef,
  $ssl_certfile = undef,
  $ssl_cert_reqs = '0',
  $ssl_ca_certs = undef,
  $databases = undef,
) {
  validate_bool($ssl)
  validate_array($databases)

  package { ['python-devel', 'python-pymongo']:
    ensure => present,
    before => Package['newrelic-plugin-agent'],
  }

  concat::fragment { "newrelic_plugin_agent-mongodb-${name}":
    order   => '07',
    target  => '/etc/newrelic/newrelic-plugin-agent.cfg',
    content => template('newrelic_agent/newrelic_plugin_agent/mongodb.erb'),
  }
}
