# == Class: newrelic_agent
#
# Full description of class newrelic_agent here.
#
# === Parameters
#
# [*sysmond_pkg*]
#   This is the name of the package for the NewRelic system monitoring daemon.
#
# [*sysmond_pkg_ensure*]
#   This controls the installation of the system monitoring daemon, defaults
#   to 'latest', can be set to a specific version or set to 'absent' to remove it.
#
# [*sysmond_svc_enable*]
#   This controls the state of system monitoring daemon service, defaults
#   to 'true'.  Can be to 'false' to stop and disable the service.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*newrelic_license_key*]
#   This is the license key for your NewRelic account and must be provided for
#   this module to work.
#
# === Examples
#
#  This will install the newrelic sysmond agent and configure it to report to your
#  NewRelic account:
#
#  class { newrelic_agent:
#    newrelic_license_key => 'abc123xyz',
#  }
#
# === Authors
#
# Joseph Swick <joseph.swick@meltwater.com>
#
# === Copyright
#
# Copyright 2013 Meltwater Group, unless otherwise noted.
#
# Licensed under Apache License, Version 2.0
#
class newrelic_agent (
  $newrelic_license_key = undef,
  $sysmond_pkg = $newrelic_agent::params::sysmond_pkg,
  $sysmond_pkg_ensure = $newrelic_agent::params::sysmond_pkg_ensure,
  $sysmond_svc_enable = $newrelic_agent::params::sysmond_svc_enable,
) inherits newrelic_agent::params {
  validate_string($newrelic_license_key)
  validate_string($sysmond_pkg)
  validate_string($sysmond_pkg_ensure)
  validate_bool($sysmond_svc_enable)

  $sysmond_svc = $newrelic_agent::params::sysmond_svc
  $sysmond_cfg = $newrelic_agent::params::sysmond_cfg

  #Install the Newrelic repo
  case $::osfamily {
    'RedHat' : {
      package { $newrelic_agent::params::newrelic_repo_pkg :
        ensure   => 'present',
        provider => 'rpm',
        source   => $newrelic_agent::params::newrelic_repo_src,
      }
    }
  }

  #Manage the sysmond package and service
  package { $sysmond_pkg:
    ensure => $sysmond_pkg_ensure,
  }

  if $sysmond_svc_enable {
    $sysmond_svc_ensure = 'running'
  } else {
    $sysmond_svc_ensure = 'stopped'
  }

  if $sysmond_pkg_ensure != 'absent' {
    file { $sysmond_cfg:
      ensure  => 'present',
      content => template("${module_name}/nrsysmond.cfg.erb"),
      require => Package[$sysmond_pkg],
    }
    service { $sysmond_svc:
      ensure    => $sysmond_svc_ensure,
      enable    => $sysmond_svc_enable,
      require   => [File[$sysmond_cfg], Package[$sysmond_pkg]],
      subscribe => File[$sysmond_cfg],
    }
  }
}
