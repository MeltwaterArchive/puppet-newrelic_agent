puppet-newrelic_agent
=====================

Puppet Module for Installing &amp; Managing the various NewRelic server monitoring agents.

This module tries to expose all of the configuration settings that NewRelic provides for their monitoring agents.  All of the default values for the parameters are taken from the configuration files provided by NewRelic for the agents.

Usage
=====================

All of the sub-classes to this module have a depenency of the main class to set your NewRelic license key.

A simple installation of this module would consist of the following:

class { newrelic_agent:
  newrelic_license_key => 'abc123xyz',
}

class { 'newrelic_agent::php':
  php_agent_appname => 'My PHP Application',
  notify_service    => 'httpd',
}

This will setup the sysmond agent in the main class for hardware monitoring, then install the PHP agent for NewRelic and then notify the httpd service to reload to initialize the monitoring agent.

