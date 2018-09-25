# This class configures the limits and sysctl parameters based on the valuse
# provided in sap::param::config_sysctl
#
# @summary Configures sysctl and limits for the selected systems.
#
class sap::config::base {

  # Configure Kernel Parameters
  $sap::params::config_sysctl.each | $component, $parameters | {
    if $component in $sap::enabled_components {
      $path = $parameters['path']
      $sequence = $parameters['sequence']

      $sysctl_arguments = {
        'header_comment' => $parameters['header_comment'],
        'entries'        => $parameters['entries'],
      }

      file { "${path}/${sequence}-sap-${component}.conf":
        ensure  => file,
        mode    => '0644',
        content => epp($parameters['template'], $sysctl_arguments);
      }
    }
  }

  file { $sap::params::config_limits_conf:
    ensure  => file,
    mode    => '0644',
    content => template($sap::params::config_limits_conf_template);
  }
}
