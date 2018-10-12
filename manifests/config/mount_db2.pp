# Ensures all relevant DB2 specific mount points exist
class sap::config::mount_db2 {
  # Baseline directories
  file { '/db2':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # SID Specific directories
  $sap::system_ids.each | $sid | {
    $sid_upper = $sid
    $sid_lower = downcase($sid)

    # Base SID folder
    file { "/db2/${sid_upper}":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File['/db2'],
    }

    # Instance Owner Home Directory
    file { "/db2/db2${sid_lower}":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File['/db2'],
    }

    # Primary log directory
    file { "/db2/${sid_upper}/log_dir":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File["/db2/${sid_upper}"],
    }

    # Log archive alternate method location
    file { "/db2/${sid_upper}/log_archive":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File["/db2/${sid_upper}"],
    }

    # Debug and dump directory
    file { "/db2/${sid_upper}/db2dump":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File["/db2/${sid_upper}"],
    }

    # Instance Home
    file { "/db2/${sid_upper}/db2${sid_lower}":
      ensure  => directory,
      owner   => "db2${sid_lower}",
      group   => "db${sid_lower}adm",
      mode    => '0755',
      require => File["/db2/${sid_upper}"],
    }

    # Data Directories
    $data_count = $sap::database_dir_counts[$sid]['data']
    unless($data_count == 0) {
      Integer[1, $data_count].each | $number | {
        file { "/db2/${sid_upper}/sapdata${number}":
          ensure  => directory,
          owner   => "db2${sid_lower}",
          group   => "db${sid_lower}adm",
          mode    => '0750',
          require => File["/db2/${sid_upper}"],
        }
      }
    }

    # Temp Directories
    $temp_count = $sap::database_dir_counts[$sid]['temp']
    unless($temp_count == 0) {
      Integer[1, $temp_count].each | $number | {
        file { "/db2/${sid_upper}/saptmp${number}":
          ensure  => directory,
          owner   => "db2${sid_lower}",
          group   => "db${sid_lower}adm",
          mode    => '0750',
          require => File["/db2/${sid_upper}"],
        }
      }
    }
  }
}
