# Class: sap::install
#
# This class install the package requirements for SAP Netweaver
#
# Parameters:   This class has no parameters
#
# Actions:      This class has no actions
#
# Requires:     This class has no requirements
#
# Sample Usage:
#
class sap::install {

  sap::install::package_set { 'common':
    package_list  => $sap::params::packages_common,
  }

  if $sap::base {
    sap::install::package_set { 'base':
      package_list  => $sap::params::packages_base,
    }
  }

  if $sap::base_extended {
    sap::install::package_set { 'base_extended':
      package_list  => $sap::params::packages_base_extended,
    }
  }

  if $sap::ads {
    sap::install::package_set { 'ads':
      package_list  => $sap::params::packages_ads,
    }
  }

  # Attempt to install RHEL 7.x applications
  if $sap::bo or $sap::cloudconnector or $sap::hana {
    if $facts['os']['release']['major'] != '7' {
      fail('HANA, Business Objects, and Cloud Connector are only supported on 7.x or greater!')
    }

    if $sap::bo {
      sap::install::packages_set { 'bo':
        package_list  => $sap::params::packages_bo,
      }
    }

    if $sap::cloudconnector {
      sap::install::packages_set { 'cloudconnector':
        package_list  => $sap::params::packages_cloudconnector,
      }
    }

    if $sap::hana {
      sap::install::packages_set { 'hana':
        package_list  => $sap::params::packages_hana,
      }
    }
  }

  # Experimental support
  if $sap::experimental {
    sap::install::package_set { 'experimental':
      package_list  => $sap::params::packages_experimental,
    }

    if $sap::router {
      sap::install::packages_set { 'saprouter':
        package_list  => $sap::params::packages_saprouter,
      }
    }
  }
}
