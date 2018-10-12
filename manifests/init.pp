# This module manages SAP prerequisites for several types of SAP installations
# based on corresponding SAP OSS notes
#
# @summary Installs prerequisites for an SAP environment on RedHat derivatives
#
# @param system_ids [Array[Pattern[/^[A-Z0-9]{3}$/]]]
#   An array of SAP system IDs (SIDs) which will be present on the target host.
#   Note that each entry must be exactly 3 characters in length and contain
#   exclusively uppercase characters.
#
# @param enabled_components [Array[Enum]]
#   List of components which will be present on the target system. Note that
#   this is an enum which includes the following valid options:
#   * `base`: SAP ABAP, JAVA stack, SAP ADS or SAP BO is used
#   * `base_extended`: ADS, Business Objects, and HANA require this
#   * `experimental`: needed for special features like SAP router
#   * `ads`: Adobe Document Services has additional requirements
#   * `bo`: Business Objects has other additional requirements
#   * `cloudconnector`: SAP Cloud Connector
#   * `router`: Configures the SAP router service on this machine
#
# @param create_mount_points [Boolean]
#   Indicates whether the standard mount points should be created for the
#   specified instance.
#
# @param router_oss_realm [Optional[String]]
#   Specify OSS realm for SAP router connection. For example,
#   `'p:CN=hostname.domain.tld, OU=0123456789, OU=SAProuter, O=SAP, C=DE'`
#
# @param router_rules [Optional[Array[String]]]
#   Specify array of rules for the SAP router
#
# @param distro_text [Optional[String]]
#   Modify text in /etc/redhat-release 
#
# @param database_dir_counts [Optional[String]]
#   Controls the number of data and tmp directories which must exist for a db2
#   node. For example, if 'data' is set to 4 the following directories will be
#   created for each SID:
#     /db2/<SID>/sapdata1
#     /db2/<SID>/sapdata2
#     /db2/<SID>/sapdata3
#     /db2/<SID>/sapdata4
#
# @example Application server containing an ADS instance and a Netweaver instance
#  class { 'sap':
#    system_ids         => ['AP0', 'AP1'],
#    enabled_components => ['base', 'base_extended', 'ads'],
#  }
#
# @author Thomas Bendler <project@bendler-net.de>
# @author Phil DeMonaco <pdemon@gmail.com>
#
# Copyright 2016 Thomas Bendler
#
class sap (
  Array[Pattern[/^[A-Z0-9]{3}$/]] $system_ids = [],
  Array[Enum['base', 'base_extended', 'experimental', 'ads', 'bo',
  'cloudconnector', 'hana', 'router', 'db2']] $enabled_components = ['base'],
  Boolean $create_mount_points = false,
  Hash[Pattern[/^[A-Z0-9]{3}$/], Hash[Enum['data', 'temp'], Integer]] $database_dir_counts = {},
  Optional[String] $router_oss_realm  = undef,
  Optional[Array[String]] $router_rules = undef,
  Optional[String] $distro_text = undef
) inherits sap::params {

  # Fail if dependencies are not met
  $base_enabled = 'base' in $enabled_components
  $base_extended_enabled= 'base_extended' in $enabled_components
  $sap::params::advanced_components.each | $component | {
    if ($component in $enabled_components) {
      unless($base_enabled) {
        fail("Component '${component}' requires 'base'!")
      }
      unless($base_extended_enabled) {
        fail("Component '${component}' requires 'base_extended'!")
      }
    }
  }

  # Ensure an SID was specified
  if empty($system_ids) {
    fail('At least one SID must be specified!')
  }

  # If this is a db2 node the number of data and temp entries should be
  # specified
  if ('db2' in $enabled_components) and $create_mount_points {
    $system_ids.each | $sid | {
      unless( $sid in $database_dir_counts ) {
        fail("db2 component: ${sid} missing entry in \'database_dir_counts\'!")

      }

      # Ensure that all fields were populated
      $dir_counts = $database_dir_counts[$sid]
      unless('data' in $dir_counts and 'temp' in $dir_counts) {
        fail('db2 component: requires \'data\' and \'temp\' counts to be specified!')
      }
      unless($dir_counts['data'] >= 1) {
        fail('db2 component: there must be at least 1 data directory!')
      }
    }
  }

  # Start workflow
  if $facts['os']['family'] == 'RedHat' {
    # Ensure the install, config, and service componets happen within here
    contain sap::install
    contain sap::config
    contain sap::service

    Class['sap::install']
    -> Class['sap::config']
    ~> Class['sap::service']
  } else {
    warning('The current operating system is not supported!')
  }
}
