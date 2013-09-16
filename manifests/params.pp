#Default Paremeters for newrelic_Agent
class newrelic_agent::params {
  case $::osfamily {
    'RedHat': {
      $newrelic_repo_pkg = 'newrelic-repo-5-3.noarch'
      $newrelic_repo_src = "https://yum.newrelic.com/pub/newrelic/el5/x86_64/${newrelic_repo_pkg}.rpm"
    }
    default : {
      fail ("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
    }
  }

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
}
