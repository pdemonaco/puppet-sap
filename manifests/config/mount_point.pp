# @param mount_path [String]
#   The path to the mountpoint. Note that this is a namevar.
#
# @param file_params [Hash[String, String]]
#   Any valid parameter which could be provided to a File resource type can be
#   included in this hash. Note that ensure is always set to `directory`.
#
# @param sid [Optional[String]]
#   The SID for this mount_point if it is an SID specific entity.
#
# @param count [Optional[Integer]]
#   Indicates that this path should be created $count times. The path must
#   contain the string `_N_` which will be substituted with the count.
#   For example `/db2/ECP/sapdata_N_` 
#   
# @param mount_parameters [Optional[Hash]]
#   TODO - fill out this section
#
# @param required_files [Optional[Array[String]]]
#   Ordered list of files which this mount point should require.
define sap::config::mount_point (
  String $mount_path                      = $name,
  Hash[String, String] $file_params       = [],
  Optional[String] $sid                   = undef,
  Optional[Integer] $count                = undef,
  Optional[Hash] $mount_parameters        = {},
  Optional[Array[String]] $required_files = []
) {
  # Ensure name contains '_N_' when count is specified
  if $count and $mount_path !~ /_N_/ {
    fail("mount_point: '${mount_path}' specifies \$count but does not contain '_N_'!")
  } elsif $count and $count < 1 {
    fail("mount_point: '${mount_path}' specifies \$count not >= 1!")
  }

  # Ensure that the mount_path contains a _SID_ or _sid_ if an SID is specified
  if $sid and ($mount_path !~ /_sid_/) and ($mount_path !~ /_SID_/) {
    fail("mount_point: SID specified for '${mount_path}' but does not contain '_sid_' or '_SID_'!")
  }

  # Construct the updated entry details if it's SID specific
  if $sid {
    $sid_upper = $sid
    $sid_lower = downcase($sid)

    $sid_path_partial = regsubst($mount_path, '_SID_', $sid_upper, 'G')
    $updated_mount_path = regsubst($sid_path_partial, '_sid_', $sid_lower, 'G')
    $updated_file_params = {
      owner => regsubst($file_params['owner'], '_sid_', $sid_lower, 'G'),
      group => regsubst($file_params['group'], '_sid_', $sid_lower, 'G'),
      mode  => $file_params['mode'],
    }

    unless(empty($required_files)) {
      $updated_required_files = $required_files.map | $require_entry | {
        $require_pass_1 = regsubst($require_entry, '_SID_', $sid_upper, 'G')
        regsubst($require_pass_1, '_sid_', $sid_lower, 'G')
      }
    } else {
      $updated_required_files = []
    }

    # TODO - making mounting data SID specific
  } else {
    $updated_mount_path = $mount_path
    $updated_file_params = $file_params
    $updated_required_files = $required_files
  }

  # Create the directory as specified or create "count" instances
  unless($count) {
    file { $updated_mount_path:
      ensure => 'directory',
      *      => $updated_file_params,
    }

    # Dependencies - might be redundant due to autodepend
    $updated_required_files.each | $file | {
      File[$file] -> File[$updated_mount_path]
    }
  } else {
    Integer[1, $count].each | $idx | {
      $idx_string = String.new($idx)
      $mount_path_idx = regsubst($updated_mount_path, '_N_', $idx_string, 'G')
      file { $mount_path_idx:
        ensure => 'directory',
        *      => $updated_file_params,
      }

      # Count specific dependencies
      $updated_required_files.each | $file | {
        File[$file] -> File[$mount_path_idx]
      }
    }
  }

  # TODO - Mounting (NFS) if relevant
}
