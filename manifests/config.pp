# Orchestrates the creation of relevant configuration files needed by SAP
#
# @summary Private class used to control configuration file deployment.
#
class sap::config {

  contain sap::config::common
  contain sap::config::sysctl
  contain sap::config::limits

  if 'router' in $sap::enabled_components {
    contain sap::config::router
  }
}
