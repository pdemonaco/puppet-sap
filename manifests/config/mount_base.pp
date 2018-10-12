# Creates standard SAP paths for baseline instances
class sap::config::mount_base {
  # TODO - figure out how to decide if we need DAA
  # probably some setting related to whether this is abap or not

  # Create the non instance specific directories
  file { '/usr/sap':
    ensure => directory,
    owner  => 'root',
    group  => 'sapsys',
    mode   => '0755',
  }

  file { '/usr/sap/trans':
    ensure  => directory,
    owner   => 'root',
    group   => 'sapsys',
    mode    => '0755',
    require => File['/usr/sap'],
  }

  # Create the mount points for each SID on this host
  $sap::system_ids.each | $sid | {
    $sid_upper = $sid
    $sid_lower = downcase($sid)

    $sidadm = "${sid_lower}adm"

    # Create the local instance home
    file { "/usr/sap/${sid_upper}":
      ensure  => directory,
      owner   => $sidadm,
      group   => 'sapsys',
      mode    => '0755',
      require => File['/usr/sap'],
  }
}
