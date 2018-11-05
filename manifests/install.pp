# Packages are installed based on the selections provided to the main sap class
# using sane defaults configured in hiera.
#
# @summary Installs the packages associated with the selected sets
#
class sap::install {

  sap::install::package_set { 'common':
    package_list  => $sap::params::packages_common,
  }

  if 'base' in $sap::enabled_components {
    sap::install::package_set { 'base':
      package_list  => $sap::params::packages_base,
    }
  }

  if 'base_extended' in $sap::enabled_components {
    sap::install::package_set { 'base_extended':
      package_list  => $sap::params::packages_base_extended,
    }
  }

  if 'ads' in $sap::enabled_components {
    sap::install::package_set { 'ads':
      package_list  => $sap::params::packages_ads,
    }
  }

  # Attempt to install RHEL 7.x applications
  $sap::params::rhel7_components.each | $component | {
    if $component in $sap::enabled_components {
      if $facts['os']['release']['major'] != '7' {
        warning("${component} is only supported on 7.x or greater!")
      } else {
        case $component {
          'bo': {
            sap::install::package_set { 'bo':
              package_list  => $sap::params::packages_bo,
            }
          }
          'cloudconnector': {
            sap::install::package_set { 'cloudconnector':
              package_list  => $sap::params::packages_cloudconnector,
            }
          }
          'hana': {
            sap::install::package_set { 'hana':
              package_list  => $sap::params::packages_hana,
            }
          }
          default: {
            fail("Invalid component '${component} - this error should be impossible!")
          }
        }
      }
    }
  }

  # Experimental support
  if 'experimental' in $sap::enabled_components {
    sap::install::package_set { 'experimental':
      package_list  => $sap::params::packages_experimental,
    }

    if 'router' in $sap::enabled_components {
      sap::install::package_set { 'saprouter':
        package_list  => $sap::params::packages_saprouter,
      }
    }
  }

  # Mount point dependencies
  if $sap::manage_mount_dependencies {
    contain sap::install::mount_dependencies
  }
}
