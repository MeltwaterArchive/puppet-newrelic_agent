# newrelic_agent::newrelic_plugin_agent::memcached_instance
class newrelic_agent::newrelic_plugin_agent::memcached_instance ($instance) {
  $real_instance = hiera_hash(newrelic_agent::newrelic_plugin_agent::memcached_instance::instance)
  create_resources(newrelic_agent::newrelic_plugin_agent::memcached, $real_instance)
}
