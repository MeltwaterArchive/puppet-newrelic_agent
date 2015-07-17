# This manages the newrelic-plugin-agent process from 
# https://github.com/MeetMe/newrelic-plugin-agent
#
# Requires the main newrelic_agent class to provide the license key
#
# Most of this is based on https://github.com/rlex/puppet-newrelic_plugin_agent
#
# === Parameters
#
# [*epel_repo_name*]
#   Default: epel
#   Name of EPEL yum repository
#
# [*newrelic_api_timeout*]
#   Default: 10 seconds
#   How long to wait for NewRelic API calls
#
# [*wake_interval*]
#   Default: 60 seconds
#   How often to send data
#
# [*manage_svc*]
#   Default: True
#   Allow for disabling the management of the agent service via puppet
#
# [*manage_pkg*]
#   Default: True
#   Allow for overriding the package management of this module
#
# [*service_ensure*]
#   Default: running
#   Override the default state of the service
#
# [*proxy*]
#   Default: undef
#   If a proxy is required to reach the NewRelic API
#
# [*pidfile*]
#   Default: /var/run/newrelic/newrelic-plugin-agent.pid
#   Full path to the PID file
#
# [*version*]
#   Default: installed
#   Specify a specific version of the newrelic-plugin-agent python package
#
class newrelic_agent::newrelic_plugin_agent (
  $epel_repo_name = 'epel',
  $newrelic_api_timeout = '10',
  $wake_interval = '60',
  $manage_svc = true,
  $manage_pkg = true,
  $service_ensure = 'running',
  $user = 'newrelic',
  $proxy = undef,
  $pidfile = '/var/run/newrelic/newrelic-plugin-agent.pid',
  $version = 'installed',
) {
  validate_bool($manage_pkg)
  validate_bool($manage_svc)

  # Resource ordering, this module depends on the main newrelic_agent class.
  Class['newrelic_agent'] -> Class['newrelic_agent::newrelic_plugin_agent']

  $license_key = $::newrelic_agent::newrelic_license_key

  package { 'python-pip':
    ensure => installed,
    require => Yumrepo[$epel_repo_name],
  }

  if ($manage_pkg) {
    package { 'newrelic-plugin-agent':
      ensure   => $version,
      provider => 'pip',
      require  => Package['python-pip'],
    }
  }

  file { '/etc/init.d/newrelic-plugin-agent':
    content => template('newrelic_agent/newrelic_plugin_agent/newrelic-plugin-agent.init'),
    mode    => '0755',
  }

  if ($manage_svc) {
    service { 'newrelic-plugin-agent':
      enable  => true,
      ensure  => $service_ensure,
      require => [ Package['newrelic-plugin-agent'],
                   File['/etc/init.d/newrelic-plugin-agent'],
                   Concat['/etc/newrelic/newrelic-plugin-agent.cfg'],
                 ],
    }
  }

  include concat::setup

  concat::fragment { 'newrelic_plugin_agent-header':
    order   => '01',
    target  => '/etc/newrelic/newrelic-plugin-agent.cfg',
    content => template('newrelic_agent/newrelic_plugin_agent/newrelic-plugin-agent-header.cfg.erb'),
    require => Package['newrelic-plugin-agent'],
  }

  concat::fragment { 'newrelic_plugin_agent-footer':
    order   => '99',
    target  => '/etc/newrelic/newrelic-plugin-agent.cfg',
    content => template('newrelic_agent/newrelic_plugin_agent/newrelic-plugin-agent-footer.cfg.erb'),
    require => Package['newrelic-plugin-agent'],
  }

  concat { '/etc/newrelic/newrelic-plugin-agent.cfg':
    notify  => Service['newrelic-plugin-agent'],
  }
}
