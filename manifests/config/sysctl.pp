# This class configures the sysctl parameters based on the values
# provided in sap::param::config_sysctl for each enabled component
#
# @summary Configures sysctl parameters for the selected components.
#
class sap::config::sysctl {

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
        content => epp($parameters['template'], $sysctl_arguments),
      }
    }
  }
}
