# This class configures the limits and sysctl parameters based on the valuse
# provided in sap::param::config_sysctl
#
# @summary Configures sysctl and limits for the selected systems.
#
class sap::config::base {

  file { $sap::params::config_limits_conf:
    ensure  => file,
    mode    => '0644',
    content => template($sap::params::config_limits_conf_template);
  }
}
