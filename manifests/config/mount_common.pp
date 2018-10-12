# Ensures the mount points exist for standard directories
class sap::config::mount_common {
  # Create the sapmnt directory
  file { '/sapmnt':
    ensure => directory,
    owner  => 'root',
    group  => 'sapsys',
    mode   => '0755',
  }

  # Generate any SID specific directories
  $sap::system_ids.each | $sid | {
    $sid_upper = $sid
    $sid_lower = downcase($sid)

    $sidadm = "${sid_lower}adm"

    # Create the sapmnt Point - even databases need this
    file { "/sapmnt/${sid_upper}":
      ensure  => directory,
      owner   => $sidadm,
      group   => 'sapsys',
      mode    => '0755',
      require => File['/sapmnt'],
    }
  }
}
