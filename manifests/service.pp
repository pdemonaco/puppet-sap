# Class: sap::service
#
# This class contain the service configuration for SAP Netweaver
#
# Parameters:   This class has no parameters
#
# Actions:      This class has no actions
#
# Requires:     This class has no requirements
#
# Sample Usage:
#
class sap::service {
  # SAP Netweaver service configuration
  service { $sap::params::service_uuidd:
    ensure  => 'running',
    enable  => true,
    require => Sap::Install::Package_set['common'];
  }

  if 'cloudconnector' in $sap::enabled_components and
    $facts['os']['release']['major'] == '7' {
    include ::sap::service::cloudconnector
  }

  if 'router' in $sap::enabled_components {
    include ::sap::service::router
  }
}
