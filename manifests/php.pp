# This manages the NewRelic PHP agent
# Requires the main newrelic_agent class to setup the installation repository
# and provide the license key
#
# === Parameters
#
# [*agent_pkg_ensure*]
#   This controls the installation of the php monitoring agent, defaults
#   to 'present', can be set to a specific version, 'latest' or set to 'absent'
#   to remove it.
#
# [*daemon_agent_startup*]
#   This controls the startup mode of the NewRelic proxy daemon.  The default is
#   'true' which puts it in the NewRelic default agent startup mode.
#   Setting this to 'false' puts it in external startup mode.
#
# [*daemon_svc_enable*]
#   This controls the state of NewRelic daemon service, defaults to 'true'.
#   Can be to 'false' to stop and disable the service.  Only applicable if
#   [*daemon_agent_startup*] is set to false.
#
# [*notify_service*]
#   (Optional) If you have a service that you're managing elsewhere with Puppet, putting
#   the name of that service (ie: httpd) in this parameter will trigger a refresh
#   notification to that service if the newrelic.ini file changes.
#
# === Settings
#
# Please refer to the NewRelic PHP Agent documentation for what each of the following
# settings control:  https://newrelic.com/docs/php/php-agent-phpini-settings
#
# This just lists the parameter and which setting it controls, params.pp uses the
# defaults from NewRelic:
#  $agent_appname => newrelic.appname
#  $agent_browser_mon_auto_inst => newrelic.browser_monitoring.auto_instrument
#  $agent_capture_params => newrelic.capture_params
#  $agent_enable => newrelic.enabled
#  $agent_error_collector_enable => newrelic.error_collector.enabled
#  $agent_error_collector_record_database_errors => newrelic.error_collector.record_database_errors
#  $agent_error_collector_pri_api => newrelic.error_collector.prioritize_api_errors
#  $agent_framework => newrelic.framework
#  $agent_ignored_params = newrelic.ignored_params
#  $agent_logfile => newrelic.logfile
#  $agent_loglevel => newrelic.loglevel
#  $agent_transaction_tracer_enable = newrelic.transaction_tracer.enabled
#  $agent_transaction_tracer_threshold => newrelic.transaction_tracer.threshold
#  $agent_transaction_tracer_detail => newrelic.transaction_tracer.detail
#  $agent_transaction_tracer_slow_sql => newrelic.transaction_tracer.slow_sql
#  $agent_transaction_tracer_stack_trace_threshold => newrelic.transaction_tracer.stack_trace_threshold
#  $agent_transaction_tracer_explain_enabled => newrelic.transaction_tracer.explain_enabled
#  $agent_transaction_tracer_explain_threshold => newrelic.transaction_tracer.explain_threshold
#  $agent_transaction_tracer_record_sql => newrelic.transaction_tracer.record_sql
#  $agent_transaction_tracer_custom => newrelic.transaction_tracer.custom
#  $agent_webtransaction_name_remove_trailing_path => newrelic.webtransaction.name.remove_trailing_path
#  $agent_webtransaction_name_functions => newrelic.webtransaction.name.functions
#  $agent_webtransaction_name_files => newrelic.webtransaction.name.files
#
# PHP daemon parameters (these go into the newrelic.cfg is agent_startup is set to false)
#  $daemon_auditlog => newrelic.daemon.auditlog
#  $daemon_collector_host => newrelic.daemon.collector_host
#  $daemon_location => newrelic.daemon.location
#  $daemon_logfile => newrelic.daemon.logfile
#  $daemon_loglevel => newrelic.daemon.loglevel
#  $daemon_max_threads => newrelic.daemon.max_threads
#  $daemon_pidfile => newrelic.daemon.pidfile
#  $daemon_port => newrelic.daemon.port
#  $daemon_proxy => newrelic.daemon.proxy
#  $daemon_ssl => newrelic.daemon.ssl
#
# === Examples
# To just do a basic installation of the New relic agent, you can do the following,
# it will setup the PHP agent using the default settings, then notify apache (httpd)
# to reload:
#
#  class { 'newrelic_agent::php':
#    agent_appname => 'My PHP Application',
#    notify_service    => 'httpd',
#  }
#
class newrelic_agent::php (
  $notify_service = undef,
  #PHP Agent Parameters
  $agent_pkg_ensure = 'present',
  $agent_appname = 'PHP Application',
  $agent_browser_mon_auto_inst = true,
  $agent_capture_params = false,
  $agent_enable = true,
  $agent_error_collector_enable = true,
  $agent_error_collector_record_database_errors = false,
  $agent_error_collector_pri_api = false,
  $agent_framework = '',
  $agent_ignored_params = undef,
  $agent_logfile = '/var/log/newrelic/php_agent.log',
  $agent_loglevel = 'info',
  $agent_transaction_tracer_enable = true,
  $agent_transaction_tracer_threshold = 'apdex_f',
  $agent_transaction_tracer_detail = 1,
  $agent_transaction_tracer_slow_sql = true,
  $agent_transaction_tracer_stack_trace_threshold = '500',
  $agent_transaction_tracer_explain_enabled = true,
  $agent_transaction_tracer_explain_threshold = '500',
  $agent_transaction_tracer_record_sql = 'obfuscated',
  $agent_transaction_tracer_custom = undef,
  $agent_webtransaction_name_remove_trailing_path = false,
  $agent_webtransaction_name_functions = undef,
  $agent_webtransaction_name_files = undef,
  #PHP daemon parameters
  $daemon_agent_startup = true,
  $daemon_auditlog = undef,
  $daemon_collector_host = 'collector.newrelic.com',
  $daemon_location = '/usr/bin/newrelic-daemon',
  $daemon_logfile = '/var/log/newrelic/newrelic-daemon.log',
  $daemon_loglevel = 'info',
  $daemon_max_threads = '8',
  $daemon_pidfile = '/var/run/newrelic-daemon.pid',
  $daemon_port = '/tmp/.newrelic.sock',
  $daemon_proxy = undef,
  $daemon_ssl = true,
  $daemon_svc_enable = true,
  ) {
  if ! defined(Class['newrelic_agent']) {
    fail('You must include the newrelic_agent base class before adding any other monitoring agents')
  }

  Class['newrelic_agent'] -> Class['newrelic_agent::php']

  #Get license key from main class
  $newrelic_license_key = $::newrelic_agent::newrelic_license_key

  $agent_pkg = 'newrelic-php5'
  $daemon_svc = 'newrelic-daemon'

  case $::osfamily {
    'RedHat' : {
      #PHP Agent Parameters
      $agent_conf_dir = '/etc/php.d'
    }
    default : {
      fail ("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
    }
  }

  package { $agent_pkg:
    ensure => $agent_pkg_ensure,
  }

  if $agent_pkg_ensure != 'absent' {
    exec { 'newrelic-install':
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      command     => "/usr/bin/newrelic-install purge && NR_INSTALL_SILENT=yes, NR_INSTALL_KEY=${newrelic_license_key} /usr/bin/newrelic-install install",
      user        => 'root',
      group       => 'root',
      unless      => "grep ${newrelic_license_key} ${agent_conf_dir}/newrelic.ini",
      require     => Package[$agent_pkg],
    }

    if $daemon_agent_startup == true {
      file {'/etc/newrelic/newrelic.cfg':
        ensure => absent,
      }

      service { $daemon_svc:
        enable    => false,
        before    => File["${agent_conf_dir}/newrelic.ini"],
      }
    } else {
      if $daemon_svc_enable {
        $daemon_svc_ensure = 'running'
      } else {
        $daemon_svc_ensure = 'stopped'
      }

      file {'/etc/newrelic/newrelic.cfg':
        ensure  => present,
        content => template("${module_name}/newrelic.cfg.erb"),
        require => Exec['newrelic-install'],
      }

      service { $daemon_svc:
        ensure    => $daemon_svc_ensure,
        enable    => $daemon_svc_enable,
        require   => File['/etc/newrelic/newrelic.cfg'],
        before    => File["${agent_conf_dir}/newrelic.ini"],
        subscribe => File['/etc/newrelic/newrelic.cfg'],
      }
    }

    file { "${agent_conf_dir}/newrelic.ini":
      ensure  => present,
      content => template("${module_name}/newrelic.ini.erb"),
      require => Exec['newrelic-install'],
    }

    if $notify_service {
      File["${agent_conf_dir}/newrelic.ini"] {
        notify +> Service[$notify_service],
      }
    }
  }

}
