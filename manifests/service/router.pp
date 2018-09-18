# Class: sap::service::router
#
# This module contain the service configuration for SAP Router
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage:
#
class sap::service::router {

  # SAP Router service configuration
  service { $sap::params::service_saprouter:
    ensure  => 'running',
    enable  => true,
    require => Sap::Install::Package_set[$sap::params::packages_saprouter];
  }
}
