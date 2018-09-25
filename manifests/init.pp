# This module manages SAP prerequisites for several types of SAP installations
# based on corresponding SAP OSS notes
#
# @summary Installs prerequisites for an SAP environment on RedHat derivatives
#
# @param base
#   Set to true when SAP ABAP, JAVA stack, SAP ADS or SAP BO is used
#   Default value is false
#
# @param base_ext
#   Set to true when SAP ADS or SAP BO is used
#   Default value is false
#
# @param experimental
#   Set to true when experimental features should be used
#   (i.e. SAP Router)
#   Default value is false
#
# @param ads
#   Set to true when Adobe Document Serverice is used
#   Default value is false
#
# @param bo
#   Set to true when SAP Business Objects is used
#   Default value is false
#
# @param cloudconnector
#   Set to true when SAP Cloud Connector is used
#   Default value is false
#
# @param router
#   Set to true when SAP Router is used
#   Default value is false
#
# @param router_oss_realm
#   Specify OSS realm for SAP router connection. For example,
#   `'p:CN=hostname.domain.tld, OU=0123456789, OU=SAProuter, O=SAP, C=DE'`
#   Default value is undef
#
# @param router_rules
#   Specify array of rules for the SAP router
#   Default value is undef
#
# @param distro_text
#   Modify text in /etc/redhat-release
#   Default value is undef
#
# @example ADS Application server
#
#  class { '::sap':
#    ads      => true,
#    base     => true,
#    base_ext => true
#  }
#
# === Authors
#
# Author Thomas Bendler <project@bendler-net.de>
#
# === Copyright
#
# Copyright 2016 Thomas Bendler
#
class sap (
  Array[Enum['base', 'base_extended', 'experimental', 'ads', 'bo',
  'cloudconnector', 'hana', 'router', 'db2']] $enabled_components = ['base'],
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

  # Start workflow
  if $facts['os']['family'] == 'RedHat' {
    # Ensure the install, config, and service componets happen within here
    contain sap::install
    contain sap::config
    contain sap::service

    Class['::sap::install']
    -> Class['::sap::config']
    ~> Class['::sap::service']
  } else {
    warning('The current operating system is not supported!')
  }
}
