# == Class: newrelic_agent::ruby
#
# This class is for installing and managing the Ruby Agent for NewRelic
#
# Requires the main newrelic_agent class to provide the license key
#
# === Parameters
#
# [*config_path*] (Required)
#   This is the full path of where Puppet is to put the newrelic.yml
#   configuration file for your Ruby application.
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
#   This controls whether or not to install the NewRelic agent gem directly.  The
#   default is 'true', which uses Puppet's gem provider to install the gem.
#   Set this to 'false' if you use bundler in your Ruby Application to install the
#   gem.
#
# [*notify_service*]
#   (Optional) If you have a service that you're managing elsewhere with Puppet, putting
#   the name of that service (ie: nginx) in this parameter will trigger a refresh
#   notification to that service if the newrelic.yaml file changes.
#
# [*agent_environment_hash*]
#   This is a puppet hash to configure any custom per-environment settings for the agent.
#   It has the format of:
#
#    agent_environment_hash => {
#      '<environment>' => {
#        '<setting_1>' => <value>,
#        '<setting_2>' => <value2>,
#      },
#    }
#
#
# === Settings
#
# Please refer to the NewRelic Ruby Agent documentation for what each of the following
# settings control:  https://newrelic.com/docs/ruby/ruby-agent-configuration
#
# This just lists the parameter and which setting it controls in the newrelic.yaml file.
# The default values for each parameter are the defaults from NewRelic:
#
#  $agent_enabled => agent_enabled
#  $agent_app_name => app_name
#  $agent_audit_log_enable => audit_log::enabled
#  $agent_browser_mon_auto_inst => browser_monitoring::auto_instrument
#  $agent_capture_params => capture_params
#  $agent_developer_mode => developer_mode
#  $agent_error_collector_enable => error_collector::enabled
#  $agent_error_collector_capture_source => error_collector::capture_source
#  $agent_error_collector_ignore_errors => error_collector::ignore_errors
#  $agent_error_collector_capture_memcache_keys => error_collector::capture_memcache_keys
#  $agent_log_level => log_level
#  $agent_logfile_name => log_file_name
#  $agent_logfile_path => log_file_path
#  $agent_monitor_mode => monitor_mode
#  $agent_proxy_host => proxy_host
#  $agent_proxy_port => proxy_port
#  $agent_proxy_user => proxy_user
#  $agent_proxy_pass => proxy_pass
#  $agent_ssl_enable => ssl
#  $agent_trans_tracer_enable => transaction_tracer::enabled
#  $agent_trans_tracer_trans_threshold => transaction_tracer::transaction_threshold
#  $agent_trans_tracer_record_sql => transaction_tracer::record_sql
#  $agent_trans_tracer_stack_trace_threshold => transaction_tracer::stack_trace_threshold
#  $agent_trans_tracer_explain_enabled => transaction_tracer::explain_enabled
#  $agent_trans_tracer_explain_threshold => transaction_tracer::explain_threshold
#
# === Examples
# To just do a basic installation of the New relic agent, you can do the following,
# it will setup the Ruby agent using the default settings with a custom application
# name:
#
#  class { 'newrelic_agent::ruby':
#    agent_appname  => 'My Ruby App',
#  }
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
