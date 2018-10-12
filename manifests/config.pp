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

  if 'base' in $sap::enabled_components {
    contain sap::config::tmpfs
  }

  # Create mount points
  if $sap::create_mount_points {
    contain sap::config::mount_common

    $sap::enabled_components.each | $component | {
      case $component {
        'base': { contain sap::config::mount_base }
        'db2': { contain 'sap::config::mount_db2' }
        default: {
          notify { "${component}: not relevant for mount point creation!": }
        }
      }
    }
  }
}
