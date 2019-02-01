# @summary Ensure local SAP configuration is ready for a clustered environment
# 
# Simple class which prepares the config files on this machine for a
# high-availability configuration of SAP. There are currently two components to
# this process: 1) the profile files in /sapmnt/<SID> corresponding to this
# machine are updated replacing entries for Restart_Program with Start_Program.
# 2) All `.sapenv_${HOSTNAME}.(sh|csh)` and other similar host-specific profile
# files are removed so the system will only use the `.sapenv.(sh|csh)` variants.
#
# Configuration is performed entirely based on the values of local 'sap' facts.
#
# @param packages [Array[String]]
#   Ensures that the resource agents needed for SAP configuration are installed
#   on this system. Note that defaults are provided only for RHEL 7 derivatives.
class sap::cluster::prepare (
  Optional[Array[String]] $packages = [],
){
  $hostname = $facts['hostname']

  # Ensure the facts are defined
  if $facts['sap'] != undef {
    $sid_hash = $facts['sap']['sid_hash']
  }

  # Deploy the packages if they are provided
  unless(empty($packages)) {
    $packages.each | $package | {
      package { $package:
        ensure => 'installed',
      }
    }
  } else {
    warning('sap-cluster-prepare: no packages were provided!')
  }

  # Remove hostname specific files in profile directory
  unless(empty($sid_hash)) {
    $sid_hash.each | $sid, $sid_data| {
      $sid_lower = downcase($sid)
      $instances = $sid_data['instances']

      # Database user stuff for db2
      if 'database' in $instances {
        $db_type = $instances['database']['type']
        case $db_type {
          'db2': {
            $database_home = "/db2/db2${sid_lower}"
          }
          default: {}
        }

        file {
          default:
            ensure => absent,
            ;
          "${database_home}/.sapenv_${hostname}.sh":
            ;
          "${database_home}/.sapenv_${hostname}.csh":
            ;
          "${database_home}/.dbenv_${hostname}.sh":
            ;
          "${database_home}/.dbenv_${hostname}.csh":
            ;
        }
      }

      # Cleanup Host-specific Environment files for the sidadm 
      $standard_home = "/home/${sid_lower}adm"
      file {
        default:
          ensure => absent,
          ;
        "${standard_home}/.sapsrc_${hostname}.sh":
          ;
        "${standard_home}/.sapsrc_${hostname}.csh":
          ;
        "${standard_home}/.sapenv_${hostname}.sh":
          ;
        "${standard_home}/.sapenv_${hostname}.csh":
          ;
        "${standard_home}/.j2eeenv_${hostname}.sh":
          ;
        "${standard_home}/.j2eeenv_${hostname}.csh":
          ;
        "${standard_home}/.dbenv_${hostname}.sh":
          ;
        "${standard_home}/.dbenv_${hostname}.csh":
          ;
      }

      # Iterate through the instances on this machine and replace "Restart" with
      # "Start" in each of the start profiles
      $instances.each | $inst_id, $inst_data | {
        $inst_type = $inst_data['type']
        $profiles = $inst_data['profiles']
        case $inst_type {
          /ERS/, /SCS/: {
            # Iterate through the profiles and update the Restart_Program_
            # lines to say Start_Program instead
            $profiles.each | $profile_path | {
              exec { "sed -i 's/^Restart_Program/Start_Program/' ${profile_path}":
                path   => '/sbin:/bin:/usr/sbin:/usr/bin',
                onlyif => [
                  "test -f ${profile_path}",
                  "test 0 -eq \$(grep \"^Restart_Program\" ${profile_path} >/dev/null; echo $?)",
                ],
              }
            }
          }
          default: {}
        }
      }
    }
  }
}
