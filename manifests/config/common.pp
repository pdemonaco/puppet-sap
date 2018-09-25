# Overwrites the distro text file to trick SAP into thinking this is RHEL.
#
# @summary Trick SAP into thinking this host is running a supported RHEL
#
class sap::config::common {

  # Replace distribution string if defined
  if ($sap::distro_text != undef) {
    $local_distro_text = "${sap::distro_text}\n"
    file { $sap::params::config_redhat_release_conf:
      ensure  => file,
      mode    => '0644',
      content => $local_distro_text;
    }
  }
}
