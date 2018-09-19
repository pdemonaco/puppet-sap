# Class: sap::service::cloudconnector
#
# This module contain the service configuration for SAP Cloud Connector
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage:
#
class sap::service::cloudconnector {

  # SAP Cloud Connector services
  service { $sap::params::service_scc:
    ensure  => 'running',
    enable  => true,
    require => Sap::Install::Package_set['cloudconnector'];
  }
}
