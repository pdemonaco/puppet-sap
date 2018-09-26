# General parameter definitions for the SAP Netweaver environment are defined
# within this module. Note that OS and Architecture specific variants are
# actually pulled from defaults in Hiera.
#
# @summary This module contains the parameters for SAP Netweaver
#
# @param packages_common [Array[String]]
#   A complete list of packages common to all distros. This is primarily uuidd,
#   however, it also includes the package sets that sapconf would deploy.
#
# @param packages_base [Array[String]]
#   These packages should be relevant to any SAP Netweaver machine.
#   
# @param packages_base_extended [Array[String]]
#   ADS, Business Objects, and HANA (1.0?) systems need these packages in
#   addition to the base set.
#   
# @param packages_ads [Array[String]]
#   Special packages uniquely required by ADS
#   
# @param packages_bo [Array[String]]
#   Special packages that Business Objects depends on.
#   
# @param packages_hana [Array[String]]
#   Special packages that HANA (1.0?) depends on.
#   
# @param packages_cloudconnector [Array[String]]
#   SAP Cloud Connector depends on a small set of SAP specific packages. These
#   appear to be SAP created. (Or they come from some other weird place).
#   
# @param packages_saprouter [Array[String]]
#   This specifies the package to install SAP Router on a given system.  
#
# @param packages_experimental [Array[String]]
#   Special SAP tools and utilities including sapcar and others... Appears to be
#   custom built?
#
# @param service_uuidd [String]
#   Name of the uuidd service. This is used to enable the daemon after the
#   installation completes.
#
# @param service_scc [String]
#   SAP Cloud Connector service name used for enabling the service.
#
# @param service_saprouter [String]
#   
# @example Simple inclusion of this package.
#   include sap::params
#
class sap::params (
  Array[String] $packages_common                        = [],
  Array[String] $packages_base                          = [],
  Array[String] $packages_base_extended                 = [],
  Array[String] $packages_ads                           = [],
  Array[String] $packages_bo                            = [],
  Array[String] $packages_hana                          = [],
  Array[String] $packages_cloudconnector                = [],
  Array[String] $packages_saprouter                     = [],
  Array[String] $packages_experimental                  = [],
  String $config_sysctl_conf                            = undef,
  String $config_sysctl_conf_template                   = undef,
  String $config_limits_conf                            = undef,
  String $config_limits_conf_template                   = undef,
  String $config_redhat_release_conf                    = undef,
  String $config_saproutetab                            = undef,
  String $config_saproutetab_template                   = undef,
  String $config_saprouter_sysconfig                    = undef,
  String $config_saprouter_sysconfig_template           = undef,
  String $service_uuidd                                 = undef,
  String $service_scc                                   = undef,
  String $service_saprouter                             = undef,
  Hash[
    String,
    Hash[
      String,
      Variant[
        String,
        Integer,
        Array[String],
        Hash[
          String,
          Variant[
            Hash[
              String,
              Variant[
                String,
                Integer,
                Array[
                  Variant[
                    String,
                    Hash[
                      String,
                      Variant[
                        String,
                        Integer,
                      ]
                    ],
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ] $config_sysctl = {},
  Hash[
    String,
    Hash[
      String,
      Variant[
        String,
        Boolean,
        Array[String],
        Hash[
          String,
          Hash[
            String,
            Hash[
              String,
              Variant[
                String,
                Integer,
              ]
            ]
          ]
        ]
      ]
    ]
  ] $config_limits = {},
){

  # These components depend on 'base' and 'base_extendend'
  $advanced_components = ['bo', 'ads', 'hana']

  # RHEL 7 only componetns
  $rhel7_components = ['bo', 'cloudconnector', 'hana']
}
