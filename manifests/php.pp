# This manages the NewRelic PHP agent
# Requires the main newrelic_agent class to setup the installation repository
# and provide the license key
#
# === Parameters
#
# [*php_agent_pkg_ensure*]
#   This controls the installation of the php monitoring agent, defaults
#   to 'present', can be set to a specific version, 'latest' or set to 'absent'
#   to remove it.
#
# [*php_daemon_agent_startup*]
#   This controls the startup mode of the NewRelic proxy daemon.  The default is
#   'true' which puts it in the NewRelic default agent startup mode.
#   Setting this to 'false' puts it in external startup mode.
#
# [*php_daemon_svc_enable*]
#   This controls the state of NewRelic daemon service, defaults to 'true'.
#   Can be to 'false' to stop and disable the service.  Only applicable if
#   [*php_daemon_agent_startup*] is set to false.
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
#  $php_agent_appname => newrelic.appname
#  $php_agent_browser_mon_auto_inst => newrelic.browser_monitoring.auto_instrument
#  $php_agent_capture_params => newrelic.capture_params
#  $php_agent_enable => newrelic.enabled
#  $php_agent_error_collector_enable => newrelic.error_collector.enabled
#  $php_agent_error_collector_record_database_errors => newrelic.error_collector.record_database_errors
#  $php_agent_error_collector_pri_api => newrelic.error_collector.prioritize_api_errors
#  $php_agent_framework => newrelic.framework
#  $php_agent_ignored_params = newrelic.ignored_params
#  $php_agent_logfile => newrelic.logfile
#  $php_agent_loglevel => newrelic.loglevel
#  $php_agent_transaction_tracer_enable = newrelic.transaction_tracer.enabled
#  $php_agent_transaction_tracer_threshold => newrelic.transaction_tracer.threshold
#  $php_agent_transaction_tracer_detail => newrelic.transaction_tracer.detail
#  $php_agent_transaction_tracer_slow_sql => newrelic.transaction_tracer.slow_sql
#  $php_agent_transaction_tracer_stack_trace_threshold => newrelic.transaction_tracer.stack_trace_threshold
#  $php_agent_transaction_tracer_explain_enabled => newrelic.transaction_tracer.explain_enabled
#  $php_agent_transaction_tracer_explain_threshold => newrelic.transaction_tracer.explain_threshold
#  $php_agent_transaction_tracer_record_sql => newrelic.transaction_tracer.record_sql
#  $php_agent_transaction_tracer_custom => newrelic.transaction_tracer.custom
#  $php_agent_webtransaction_name_remove_trailing_path => newrelic.webtransaction.name.remove_trailing_path
#  $php_agent_webtransaction_name_functions => newrelic.webtransaction.name.functions
#  $php_agent_webtransaction_name_files => newrelic.webtransaction.name.files
#  $php_daemon_port => newrelic.daemon.port
#
# PHP daemon parameters (these go into the newrelic.cfg is agent_startup is set to false)
#  $php_daemon_auditlog => newrelic.daemon.auditlog
#  $php_daemon_collector_host => newrelic.daemon.collector_host
#  $php_daemon_location => newrelic.daemon.location
#  $php_daemon_logfile => newrelic.daemon.logfile
#  $php_daemon_loglevel => newrelic.daemon.loglevel
#  $php_daemon_max_threads => newrelic.daemon.max_threads
#  $php_daemon_pidfile => newrelic.daemon.pidfile
#  $php_daemon_proxy => newrelic.daemon.proxy
#  $php_daemon_ssl => newrelic.daemon.ssl
#
# === Examples
# To just do a basic installation of the New relic agent, you can do the following,
# it will setup the PHP agent using the default settings, then notify apache (httpd)
# to reload:
#
#  class { 'newrelic_agent::php':
#    php_agent_appname => 'My PHP Application',
#    notify_service    => 'httpd',
#  }
#
class newrelic_agent::php (
  $notify_service = undef,
  #PHP Agent Parameters
  $php_agent_pkg_ensure = 'present',
  $php_agent_appname = 'PHP Application',
  $php_agent_browser_mon_auto_inst = true,
  $php_agent_capture_params = false,
  $php_agent_enable = true,
  $php_agent_error_collector_enable = true,
  $php_agent_error_collector_record_database_errors = false,
  $php_agent_error_collector_pri_api = false,
  $php_agent_framework = '',
  $php_agent_ignored_params = undef,
  $php_agent_logfile = '/var/log/newrelic/php_agent.log',
  $php_agent_loglevel = 'info',
  $php_agent_transaction_tracer_enable = true,
  $php_agent_transaction_tracer_threshold = 'apdex_f',
  $php_agent_transaction_tracer_detail = 1,
  $php_agent_transaction_tracer_slow_sql = true,
  $php_agent_transaction_tracer_stack_trace_threshold = '500',
  $php_agent_transaction_tracer_explain_enabled = true,
  $php_agent_transaction_tracer_explain_threshold = '500',
  $php_agent_transaction_tracer_record_sql = 'obfuscated',
  $php_agent_transaction_tracer_custom = undef,
  $php_agent_webtransaction_name_remove_trailing_path = false,
  $php_agent_webtransaction_name_functions = undef,
  $php_agent_webtransaction_name_files = undef,
  #PHP daemon parameters
  $php_daemon_agent_startup = true,
  $php_daemon_auditlog = undef,
  $php_daemon_collector_host = 'collector.newrelic.com',
  $php_daemon_location = '/usr/bin/newrelic-daemon',
  $php_daemon_logfile = '/var/log/newrelic/newrelic-daemon.log',
  $php_daemon_loglevel = 'info',
  $php_daemon_max_threads = '8',
  $php_daemon_pidfile = '/var/run/newrelic-daemon.pid',
  $php_daemon_port = '/tmp/.newrelic.sock',
  $php_daemon_proxy = undef,
  $php_daemon_ssl = true,
  $php_daemon_svc_enable = true,
  ) {
  if ! defined(Class['newrelic_agent']) {
    fail('You must include the newrelic_agent base class before adding any other monitoring agents')
  }

  #Get license key from main class
  $newrelic_license_key = $::newrelic_agent::newrelic_license_key

  $php_agent_pkg = 'newrelic-php5'
  $php_daemon_svc = 'newrelic-daemon'

  case $::osfamily {
    'RedHat' : {
      #PHP Agent Parameters
      $php_agent_conf_dir = '/etc/php.d'
    }
    default : {
      fail ("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
    }
  }

  package { $php_agent_pkg:
    ensure => $php_agent_pkg_ensure,
  }

  if $php_agent_pkg_ensure != 'absent' {
    exec { 'newrelic-install':
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      command     => "/usr/bin/newrelic-install purge && NR_INSTALL_SILENT=yes, NR_INSTALL_KEY=${newrelic_license_key} /usr/bin/newrelic-install install",
      user        => 'root',
      group       => 'root',
      unless      => "grep ${newrelic_license_key} ${php_agent_conf_dir}/newrelic.ini",
      require     => Package[$php_agent_pkg],
    }

    if $php_daemon_agent_startup == true {
      file {'/etc/newrelic/newrelic.cfg':
        ensure => absent,
      }

      service { $php_daemon_svc:
        enable    => false,
        before    => File["${php_agent_conf_dir}/newrelic.ini"],
      }
    } else {
      if $php_daemon_svc_enable {
        $php_daemon_svc_ensure = 'running'
      } else {
        $php_daemon_svc_ensure = 'stopped'
      }

      file {'/etc/newrelic/newrelic.cfg':
        ensure  => present,
        content => template("${module_name}/newrelic.cfg.erb"),
        require => Exec['newrelic-install'],
      }

      service { $php_daemon_svc:
        ensure    => $php_daemon_svc_ensure,
        enable    => $php_daemon_svc_enable,
        require   => File['/etc/newrelic/newrelic.cfg'],
        before    => File["${php_agent_conf_dir}/newrelic.ini"],
        subscribe => File['/etc/newrelic/newrelic.cfg'],
      }
    }

    file { "${php_agent_conf_dir}/newrelic.ini":
      ensure  => present,
      content => template("${module_name}/newrelic.ini.erb"),
      require => Exec['newrelic-install'],
    }

    if $notify_service {
      File["${php_agent_conf_dir}/newrelic.ini"] {
        notify +> Service[$notify_service],
      }
    }
  }

}
