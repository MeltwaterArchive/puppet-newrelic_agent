# == Class: newrelic_agent::ruby
#
# This class is for installing and managing the Ruby Agent for NewRelic
#
# Requires the main newrelic_agent class to provide the license key
#
# === Parameters
#
# [*config_path*] (Required)
#   This is the fill path of where Puppet is to put the newrelic.yml
#   config file for your Ruby application.
#
# [*config_owner*]
#   This sets the owner of the configuration file, default is 'root'.
#
# [*config_group*]
#   This sets the group of the configuration file, default is 'root'.
#
# [*config_mode*]
#   This sets the file permissions of the configuration file, default is '0644'.
#
# [*install_gem*]
#   This controls whether or not to install the NewRelic agent gem directly
#   Or if you want to manage its installation with bundler in your Ruby Application
#
# [*notify_service*]
#   (Optional) If you have a service that you're managing elsewhere with Puppet, putting
#   the name of that service (ie: nginx) in this parameter will trigger a refresh
#   notification to that service if the newrelic.yaml file changes.
#
# === Settings
#
# Please refer to the NewRelic Ruby Agent documentation for what each of the following
# settings control:  https://newrelic.com/docs/ruby/ruby-agent-configuration
#
# This just lists the parameter and which setting it controls.  The settings use the
# defaults from NewRelic:
#
# === Examples
#
class newrelic_agent::ruby (
  $config_path,
  $config_owner = 'root',
  $config_group = 'root',
  $config_mode = '0644',
  $install_gem = true,
  $notify_service = undef,
  #Ruby agent parameters
  $agent_enabled = 'auto',
  $agent_app_name = 'Ruby Application',
  $agent_audit_log_enable = false,
  $agent_browser_mon_auto_inst = true,
  $agent_capture_params = false,
  $agent_developer_mode = false,
  $agent_error_collector_enable = true,
  $agent_error_collector_capture_source = true,
  $agent_error_collector_ignore_errors = 'ActionController::RoutingError,Sinatra::NotFound',
  $agent_error_collector_capture_memcache_keys = false,
  $agent_log_level = 'info',
  $agent_logfile_name = 'newrelic_agent.log',
  $agent_logfile_path = '/var/log',
  $agent_monitor_mode = true,
  $agent_proxy_host = undef,
  $agent_proxy_port = undef,
  $agent_proxy_user = undef,
  $agent_proxy_pass = undef,
  $agent_ssl_enable = true,
  $agent_trans_tracer_enable = true,
  $agent_trans_tracer_trans_threshold = 'apdex_f',
  $agent_trans_tracer_record_sql = 'obfuscated',
  $agent_trans_tracer_stack_trace_threshold = '0.500',
  $agent_trans_tracer_explain_enabled = true,
  $agent_trans_tracer_explain_threshold = '0.5',
  #Environment Hash
  $agent_environment_hash = 'UNSET',
) {
  if ! defined(Class['newrelic_agent']) {
    fail('You must include the newrelic_agent base class before adding any other monitoring agents')
  }

  validate_absolute_path($config_path)

  #Get license key from main class
  $newrelic_license_key = $::newrelic_agent::newrelic_license_key

  if $agent_environment_hash == 'UNSET' {
    $agent_environment_hash_real = {
      'development' => {
        'monitor_mode'   => false,
        'developer_mode' => true,
      },
      'test'        => { 'monitor_mode' => false,},
      'production'  => { 'monitor_mode' => true,},
      'staging'     => {
        'monitor_mode' => true,
        'app_name'     => "${agent_app_name} (Staging)",
      },
    }
  } else {
    validate_hash($agent_environment_hash)
    $agent_environment_hash_real = $agent_environment_hash
  }

  if $install_gem {
    package {'newrelic_rpm':
      ensure   => 'present',
      provider => 'gem',
    }
  }

  file {"${config_path}/newrelic.yml":
    ensure  => 'present',
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    content => template("${module_name}/newrelic.yml.erb"),
  }

  if $notify_service {
    File["${config_path}/newrelic.yml"] {
      notify +> Service[$notify_service],
    }
  }
}
