# newrelic_agent::newrelic_plugin_agent::mongodb_instance
class newrelic_agent::newrelic_plugin_agent::mongodb_instance ($instance) {
  $real_instance = hiera_hash(newrelic_agent::newrelic_plugin_agent::mongodb_instance::instance)
  create_resources(newrelic_agent::newrelic_plugin_agent::mongodb, $real_instance)
}
