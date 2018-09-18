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
  Boolean $base = $sap::params::base,
  Boolean $base_extended = $sap::params::base_extended,
  Boolean $experimental = $sap::params::experimental,
  Boolean $ads = $sap::params::ads,
  Boolean $bo = $sap::params::bo,
  Boolean $cloudconnector = $sap::params::cloudconnector,
  Boolean $hana = $sap::params::hana,
  Boolean $router = $sap::params::router,
  Optional[String] $router_oss_realm  = undef,
  Optional[Array[String]] $router_rules = undef,
  Optional[String] $distro_text = undef
) inherits sap::params {

  # Fail if dependencies are not met
  if (($ads != false) or ($bo != false) or ($hana !=false)) {
    if ($base != true) {
      fail('Dependency parameter $sap::base not set to true!')
    }
    if ($base_extended != true) {
      fail('Dependency parameter $sap::base_extended not set to true!')
    }
  }

  # Start workflow
  if $facts['os']['family'] == 'RedHat' {
    # Ensure the install, config, and service componets happen within here
    contain '::sap::install'
    contain '::sap::config'
    contain '::sap::service'

    Class{ '::sap::install': }
    -> Class{ '::sap::config': }
    ~> Class{ '::sap::service': }
    -> Class['sap']
  } else {
    warning('The current operating system is not supported!')
  }
}
