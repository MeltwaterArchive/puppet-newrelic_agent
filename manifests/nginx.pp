# This manages the NewRelic Nginx Plugin provided by Nginx
# Requires the main newrelic_agent class to provide the license key
#
# There is also an implicit dependency on the Nginx.org Pagage Repo which
# contains the nginx-nr-agent package, which is not managed by this class.
#
# === Parameters
#
# [*ensure*]
#   Default: True
#   Whether the package and configuration file should be present
#
# [*manage_pkg*]
#   Default: True
#   Allow for overriding the package management of this module.
#
# [*package_name*]
#   Default: nginx-nr-agent
#   Allow overriding the default package name for the agent
#
# [*manage_svc*]
#   Default: True
#   Allow for disabling the management of the agent service via puppet
#
# [*service_ensure*]
#   Default: running
#   Override the default state of the agent service
#
# === Settings
#
# [*data_sources*]
#   Type: Hash
#   This is the hash of the endpoint stub_status pages that the agent plugin should be monitoring
#   See the README.txt from the nginx-nr-agent package for more details. (/usr/share/doc/nginx-nr-agent/README.txt)
#
#   Example:
#    data_sources => {
#      'source1' => {
#        'name' => 'testing',
#        'url'  => 'http://localhost/status',
#      },
#    }
#
class newrelic_agent::nginx (
  $ensure = 'present',
  $manage_pkg = true,
  $package_name = 'nginx-nr-agent',
  $manage_svc = true,
  $service_ensure = 'running',
  $data_sources = {},
) {
  validate_bool($manage_pkg)
  validate_hash($data_sources)

  #Resource ordering, this module depends on the main newrelic_agent class.
  Class['newrelic_agent'] -> Class['newrelic_agent::nginx']

  #Get license key from main class
  $newrelic_license_key = $::newrelic_agent::newrelic_license_key

  if ($manage_pkg) {
    package { $package_name:
      ensure => $ensure,
      before => File['nginx-nr-agent.ini'],
    }
  }

  file { 'nginx-nr-agent.ini':
    ensure  => $ensure,
    path    => '/etc/nginx-nr-agent/nginx-nr-agent.ini',
    content => template("${module_name}/nginx-nr-agent.ini.erb"),
  }

  if ($manage_svc) {
    service { 'nginx-nr-agent':
      ensure    => $service_ensure,
      require   => File['nginx-nr-agent.ini'],
      subscribe => File['nginx-nr-agent.ini'],
    }
  }
}
