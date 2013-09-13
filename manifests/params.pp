#Default Paremeters for newrelic_Agent
class newrelic_agent::params {
  case $::osfamily {
    'RedHat': {
      $sysmond_pkg = 'newrelic-sysmond'
      $sysmond_pkg_ensure = 'latest'
      $sysmond_cfg = '/etc/newrelic/nrsysmond.cfg'
      $sysmond_svc = 'newrelic-sysmond'
      $sysmond_svc_enable = true
      $newrelic_repo_pkg = 'newrelic-repo-5-3.noarch.rpm'
      $newrelic_repo_src = "https://yum.newrelic.com/pub/newrelic/el5/x86_64/${newrelic_repo_pkg}"
    }
    default : {
      fail ("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
    }
  }
}
