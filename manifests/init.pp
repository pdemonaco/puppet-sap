# This module manages SAP prerequisites for several types of SAP installations
# based on corresponding SAP OSS notes
#
# @summary Installs prerequisites for an SAP environment on RedHat derivatives
#
# @param system_ids [Array[Sap::SID]]]
#   An array of SAP system IDs (SIDs) which will be present on the target host.
#   Note that each entry must be exactly 3 characters in length and contain
#   exclusively uppercase characters.
#
# @param enabled_components [Array[Sap::SapComponents]]
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
# @param mount_points [Hash[Enum,Hash]]
#   Defines the mount points and supporting directories which should be created
#   for each component type. Note that this structure is a deep hash with a `--`
#   knockout value.
#
# @param router_oss_realm [Optional[String]]
#   Specify OSS realm for SAP router connection. For example,
#   `'p:CN=hostname.domain.tld, OU=0123456789, OU=SAProuter, O=SAP, C=DE'`
#
# @param manage_mount_dependencies [Optional[String]]
#   When enabled this module will install and configure the puppet-nfs module
#   detailed here: https://forge.puppet.com/derdanne/nfs
#   Note that currently only NFSv4 is supported for clients.
#
# @param router_rules [Optional[Array[String]]]
#   Specify array of rules for the SAP router
#
# @param distro_text [Optional[String]]
#   Modify text in /etc/redhat-release 
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
  Array[Sap::SID] $system_ids = [],
  Array[Sap::SapComponents] $enabled_components = ['base'],
  Boolean $create_mount_points = false,
  Hash[Enum['common', 'base', 'db2'], Hash] $mount_points = {},
  Boolean $manage_mount_dependencies = false,
  Optional[String] $router_oss_realm  = undef,
  Optional[Array[String]] $router_rules = undef,
  Optional[String] $distro_text = undef
) inherits sap::params {

  # Fail if dependencies are not met
  $base_enabled = 'base' in $enabled_components
  $sap::params::requires_base.each | $component | {
    if ($component in $enabled_components) {
      unless($base_enabled) {
        fail("Component '${component}' requires 'base'!")
      }
    }
  }

  $base_extended_enabled = 'base_extended' in $enabled_components
  $sap::params::requires_base_extended.each | $component | {
    if ($component in $enabled_components) {
      unless($base_extended_enabled) {
        fail("Component '${component}' requires 'base_extended'!")
      }
    }
  }

  # Ensure an SID was specified
  if empty($system_ids) {
    fail('At least one SID must be specified!')
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
