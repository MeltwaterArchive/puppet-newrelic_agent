# This manages the memcached requirements for newrelic-plugin-agent
#
# === Parameters
#
# [*host*]
#   Default: localhost
#   Host where the memcached instance is running
#
# [*port*]
#   Default: 11211
#   Port the memcached instance is listening on
#
# [*name*]
#   Default: default
#   Memcached Bucket Name
#
define newrelic_agent::newrelic_plugin_agent::memcached (
  $host = 'localhost',
  $port = '11211',
  $name = 'default',
) {

  concat::fragment { "newrelic_plugin_agent-memcached-${name}":
    order   => '08',
    target  => '/etc/newrelic/newrelic-plugin-agent.cfg',
    content => template('newrelic_agent/newrelic_plugin_agent/memcached.erb'),
  }
}
