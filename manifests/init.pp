# == Class: newrelic_agent
#
# Full description of class newrelic_agent here.
#
# === Parameters
#
# [*manage_pkg*]
#   Allow for overriding the package management of this module.
#
# [*manage_repo*]
#   Allow for overriding the repo management of this module.
#
# [*sysmond_pkg*]
#   This is the name of the package for the NewRelic system monitoring daemon.
#
# [*sysmond_pkg_ensure*]
#   This controls the installation of the system monitoring daemon, defaults
#   to 'present', can be set to a specific version, 'latest' or set to 'absent' to remove it.
#
# [*sysmond_svc_enable*]
#   This controls the state of system monitoring daemon service, defaults
#   to 'true'.  Can be to 'false' to stop and disable the service.
#
# [*sysmond_loglevel*]
#   Level of detail you want in the sysmond log file, default is 'info'.
#   See the NewRelic sysmond documentation for the valid options.
#
# [*sysmond_logfile*]
#   Full path to the local logfile for the sysmond agent, verbosity is
#   controlled by the [*sysmond_loglevel*] parameter.
#
# [*sysmond_pidfile*]
#   Full path to the PID file for the monitoring daemon.
#
# [*sysmond_collector_host*]
#   The name of the New Relic collector to connect to. This should only
#   ever be changed on advise from a New Relic support staff member.
#   The default is 'collector.newrelic.com'.
#
# [*sysmond_timeout*]
#   How long (in seconds) the daemon should wait to contact the collector host.
#   The default is '30'.
#
# [*sysmond_proxy*]
#   The name and optional login credentials of the proxy server for the daemon
#   to use when trying to connect to NewRelic.  Default value is 'undef'.
#
# [*sysmond_ssl_enable*]
#   Whether or not to enable SSL for reporting data to NewRelic, the default is
#   'false'.
#
# [*sysmond_ssl_ca_bundle*]
#   The path to a PEM encoded CA bundle for use with SSL connections, should
#   not have to be set for most systems.
#
# [*sysmond_ssl_ca_path*]
#   The path to a directory with your PEM encoded CA files if your system does
#   not use a bundled CA certificate file.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*newrelic_license_key*]
#   This is the license key for your NewRelic account and must be provided for
#   this module to work.
#
# [*sysmond_labels*]
#   Array of labels to apply to the machine
#
# === Examples
#
#  This will install the newrelic sysmond agent using the default settings and
#  configure it to report to your NewRelic account:
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
  $manage_pkg = true,
  $manage_repo = true,
  $sysmond_pkg = 'newrelic-sysmond',
  $sysmond_pkg_ensure = 'present',
  $sysmond_collector_host = 'collector.newrelic.com',
  $sysmond_logfile = '/var/log/newrelic/nrsysmond.log',
  $sysmond_loglevel = 'info',
  $sysmond_pidfile = '/var/run/newrelic/nrsysmond.pid',
  $sysmond_proxy = undef,
  $sysmond_ssl_enable = false,
  $sysmond_svc_enable = true,
  $sysmond_ssl_ca_bundle = undef,
  $sysmond_ssl_ca_path = undef,
  $sysmond_timeout = '30',
  $sysmond_labels = undef,
) {
  validate_string($newrelic_license_key)
  validate_string($sysmond_pkg)
  validate_string($sysmond_pkg_ensure)
  validate_bool($sysmond_svc_enable)
  validate_bool($manage_pkg)
  validate_bool($manage_repo)

  $sysmond_svc = 'newrelic-sysmond'
  $sysmond_cfg = '/etc/newrelic/nrsysmond.cfg'

  if !($newrelic_license_key) {
    fail("You must provide a NewRelic license key for the ${module_name} module")
  }

  #Install the Newrelic repo
  if $manage_repo {
    case $::osfamily {
      'RedHat' : {
        #Repo configuration
        $newrelic_repo_pkg = 'newrelic-repo-5-3.noarch'

        #RPM in CentOS 5 doesn't support https transfers.
        case $::operatingsystemmajrelease {
          '5' : { $newrelic_repo_src = "http://yum.newrelic.com/pub/newrelic/el5/x86_64/${newrelic_repo_pkg}.rpm" }
          default : { $newrelic_repo_src = "https://yum.newrelic.com/pub/newrelic/el5/x86_64/${newrelic_repo_pkg}.rpm" }
        }

        package { $newrelic_repo_pkg:
          ensure   => 'present',
          provider => 'rpm',
          source   => $newrelic_repo_src,
        }

        if $manage_pkg {
          Package[$newrelic_repo_pkg] -> Package[$sysmond_pkg]
        }
      }
      default : {
        fail("Unsupported osfamily: ${::osfamily} for module: ${module_name}")
      }
    }
  }

  #Manage the sysmond package and service
  if $manage_pkg {
    package { $sysmond_pkg:
      ensure => $sysmond_pkg_ensure,
      before => [Service[$sysmond_svc], File[$sysmond_cfg]],
    }
  }

  if $sysmond_svc_enable {
    $sysmond_svc_ensure = 'running'
  } else {
    $sysmond_svc_ensure = 'stopped'
  }

  if $sysmond_pkg_ensure != 'absent' {
    file { $sysmond_cfg:
      ensure  => 'present',
      owner   => 'root',
      group   => 'newrelic',
      mode    => '0640',
      content => template("${module_name}/nrsysmond.cfg.erb"),
    }
    service { $sysmond_svc:
      ensure    => $sysmond_svc_ensure,
      enable    => $sysmond_svc_enable,
      require   => File[$sysmond_cfg],
      subscribe => File[$sysmond_cfg],
    }
  }
}
