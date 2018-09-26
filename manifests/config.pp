# Orchestrates the creation of relevant configuration files needed by SAP
#
# @summary Private class used to control configuration file deployment.
#
class sap::config {

  include sap::config::common
  include sap::config::sysctl
  include sap::config::limits

  if 'router' in $sap::enabled_components {
    include sap::config::router
  }
}
