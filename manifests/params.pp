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
# @param config_redhat_release_conf [String]
#   This should point to the path of the desired redhat release config file.
#
# @param service_uuidd [String]
#   Name of the uuidd service. This is used to enable the daemon after the
#   installation completes.
#
# @param service_scc [String]
#   SAP Cloud Connector service name used for enabling the service.
#
# @param service_saprouter [String]
#   Name of the service corresponding to the SAP router process.
#
# @param config_saproutetab [String]
#   File target for the sap router route-table should it be configure.
#
# @param config_saproutetab_template [String]
#   Path within the module to the appropriate erb template to apply for the
#   saproutetab.
#
# @param config_saprouter_sysconfig [String]
#   Target /etc/sysconfig file for the saprouter service
#   
# @param config_saprouter_sysconfig_template [String]
#   Embedded ruby template to be applied to the sysconfig file
#   
# @param config_saprouter_sysconfig_template [String]
#   Embedded ruby template to be applied to the sysconfig file
#
# @param config_sysctl [Hash]
#   Similar to config_limits this provides a configurable set of directives to
#   include in /etc/sysctl.d/ on a per component basis.
#
# @param config_limits [Hash]
#   A deeply nested hash containing the target /etc/security/limits.d/
#   entries for a given system. This is currently defined for baseline sap
#   instances and db2. The hash has the following structure
#   
#   ```puppet
#   'component-name' => {
#     path           => '/etc/security/limits.d', # this should be left alone - limits directrory
#     sequence       => '00', # string ID prepended to the limits file. e.g.
#                             # /etc/security/limits.d/00-sap-base.conf
#     per_sid        => true, # Indicates whether the domain has a _sid_
#                             # substring that will need to be substituted with the actual system ID.
#     header_comment => [ # An array of comment lines which will appear at the
#                         #start of the file
#       'Comment line 1',
#       'Comment line 2',
#     ],
#     entries => { # Hash containing the actual 
#     }
#   ```
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
