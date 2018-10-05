# Ensures that the tmpfs partition is configured per SAP recommendations
# Add swap space check per 
class sap::config::tmpfs {
  # Calculate memory sizes as floats
  $gigabyte = 1073741824
  $system_gb = Float.new($facts['memory']['system']['total_bytes']) / $gigabyte
  $swap_gb = Float.new($facts['memory']['swap']['total_bytes']) / $gigabyte

  # Check that swap is of a certain size. If it's not, print a warning.
  # See https://launchpad.support.sap.com/#/notes/1597355 for detail
  if $system_gb < 32 {
    $swap_target = 2.0 * $system_gb
  } elsif $system_gb >= 32 and $system_gb < 64 {
    $swap_target = 64.0
  } elsif $system_gb >= 64 and $system_gb < 128 {
    $swap_target = 96.0
  } elsif $system_gb >= 128 and $system_gb < 256 {
    $swap_target = 128.0
  } elsif $system_gb >= 256 and $system_gb < 512 {
    $swap_target = 160.0
  } elsif $system_gb >= 512 and $system_gb < 1024 {
    $swap_target = 192.0
  } elsif $system_gb >= 1024 and $system_gb < 2048 {
    $swap_target = 224.0
  } elsif $system_gb >= 2048 and $system_gb < 4096 {
    $swap_target = 256.0
  } elsif $system_gb >= 4096 and $system_gb < 8192 {
    $swap_target = 288.0
  } else {
    $swap_target = 320.0
  }

  # If the swap is too small, warn!
  if $swap_target > $swap_gb {
    warning("SAP: Swap space may be undersized! Current ${swap_gb}, Target ${swap_target}")
  }

  # Ensure that the tmpfs is roughly ( RAM + SWAP ) * 0.75
  # per https://launchpad.support.sap.com/#/notes/941735
  $tmpfs_size_target = round(($system_gb + $swap_gb) * 0.75)

  # Calculate Current tmpfs size
  if '/dev/shm' in $facts['mountpoints'] {
    $tmpfs_size_current = ($facts['mountpoints']['/dev/shm']['size_bytes'] + $gigabyte) / $gigabyte
  } else {
    $tmpfs_size_current = 0
  }

  # Ensure the line is present in /etc/fstab
  file_line { 'fstab_tmpfs_size':
    ensure => present,
    path   => '/etc/fstab',
    line   => "tmpfs\t/dev/shm\ttmpfs\tsize=${tmpfs_size_target}g\t0 0",
    match  => '/dev/shm',
  }

  # Remount if it's not currently mounted or when the entry in fstab changes
  if $tmpfs_size_current == 0 {
    exec { 'mount_devshm':
      command => '/bin/mount /dev/shm',
    }
  } else {
    exec { 'remount_devshm':
      command     => '/bin/mount -o remount /dev/shm',
      subscribe   => File_line['fstab_tmpfs_size'],
      refreshonly => true,
    }
  }
}
