#Default Paremeters for newrelic_Agent
class newrelic_agent::params {
  case $::osfamily {
    'RedHat': {
      #Repo configuration
      $newrelic_repo_pkg = 'newrelic-repo-5-3.noarch'
      $newrelic_repo_src = "https://yum.newrelic.com/pub/newrelic/el5/x86_64/${newrelic_repo_pkg}.rpm"

      #PHP Agent Parameters
      $php_agent_conf_dir = '/etc/php.d'
    }
    default : {
      fail ("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
    }
  }

  #System Monitoring Daemon Parameters
  $sysmond_pkg = 'newrelic-sysmond'
  $sysmond_pkg_ensure = 'present'
  $sysmond_cfg = '/etc/newrelic/nrsysmond.cfg'
  $sysmond_loglevel = 'info'
  $sysmond_logfile = '/var/log/newrelic/nrsysmond.log'
  $sysmond_pidfile = '/var/run/newrelic/nrsysmond.pid'
  $sysmond_collector_host = 'collector.newrelic.com'
  $sysmond_timeout = '30'
  $sysmond_ssl_enable = false
  $sysmond_svc = 'newrelic-sysmond'
  $sysmond_svc_enable = true

  #PHP Agent Parameters
  $php_agent_pkg = 'newrelic-php5'
  $php_agent_pkg_ensure = 'present'
  $php_agent_appname = 'PHP Application'
  $php_agent_browser_mon_auto_inst = true
  $php_agent_capture_params = false
  $php_agent_enable = true
  $php_agent_error_collector_enable = true
  $php_agent_error_collector_record_database_errors = false
  $php_agent_error_collector_pri_api = false
  $php_agent_framework = ''
  $php_agent_ignored_params = undef
  $php_agent_logfile = '/var/log/newrelic/php_agent.log'
  $php_agent_loglevel = 'info'
  $php_agent_transaction_tracer_enable = true
  $php_agent_transaction_tracer_threshold = 'apdex_f'
  $php_agent_transaction_tracer_detail = 1
  $php_agent_transaction_tracer_slow_sql = true
  $php_agent_transaction_tracer_stack_trace_threshold = '500'
  $php_agent_transaction_tracer_explain_enabled = true
  $php_agent_transaction_tracer_explain_threshold = '500'
  $php_agent_transaction_tracer_record_sql = 'obfuscated'
  $php_agent_transaction_tracer_custom = undef
  $php_agent_webtransaction_name_remove_trailing_path = false
  $php_agent_webtransaction_name_functions = undef
  $php_agent_webtransaction_name_files = undef

  #PHP daemon parameters
  $php_daemon_agent_startup = true
  $php_daemon_auditlog = undef
  $php_daemon_collector_host = 'collector.newrelic.com'
  $php_daemon_location = '/usr/bin/newrelic-daemon'
  $php_daemon_logfile = '/var/log/newrelic/newrelic-daemon.log'
  $php_daemon_loglevel = 'info'
  $php_daemon_max_threads = 8
  $php_daemon_pidfile = '/var/run/newrelic-daemon.pid'
  $php_daemon_port = '/tmp/.newrelic.sock'
  $php_daemon_proxy = undef
  $php_daemon_ssl = true
  $php_daemon_svc = 'newrelic-daemon'
  $php_daemon_svc_enable = true

}
