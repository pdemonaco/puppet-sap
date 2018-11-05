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
#
# @param sid_lower_pattern [Optional[String]]
#   String pattern used to make various components SAP System ID specific. An
#   lowercase version of the sid will be inserted where this pattern is found.
#
# @param sid_upper_pattern [Optional[String]]
#   String pattern used to make various components SAP System ID specific. An
#   uppercase version of the sid will be inserted where this pattern is found.
#
# @param mount_defaults [Optional[Hash]]
#   Hash of hashes containing mount-type specific defaults. Currently this is
#   used exclusively to provide default parameters to the NFSv4 client mounts
#   for SAP related connections.
#
define sap::config::mount_point (
  String $mount_path                      = $name,
  Hash[String, String] $file_params       = [],
  Optional[String] $sid                   = undef,
  Optional[String] $sid_upper_pattern     = undef,
  Optional[String] $sid_lower_pattern     = undef,
  Optional[Integer] $count                = undef,
  Optional[Hash] $mount_parameters        = {},
  Optional[Hash] $mount_defaults          = {},
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

  # Validate the provided mount parameters
  unless(empty($mount_parameters)) {
    unless('managed' in $mount_parameters) {
      fail("mount_point: '${mount_path}' does not specify 'managed'!")
    }

    # If the mount is meant to be managed retrieve the specified parameters
    if $mount_parameters['managed'] {
      unless('type' in $mount_parameters) {
        fail("mount_point: missing mount type for path '${mount_path}'!")
      }
      $mount_type = $mount_parameters['type']

      # If it's a valid mount type determine the required attributes
      case $mount_type {
        'nfsv4': {
          # Check for nfsv4 mandatory parameters
          $required_attributes = ['server', 'share']
        }
        default: {
          fail("mount_point: invalid mount type '${mount_type}' for path '${mount_path}'!")
        }
      }

      # Fail if required attributes are missing
      $required_attributes.each | $attribute | {
        unless($attribute in $mount_parameters) {
          fail("mount_point: '${mount_path}' type '${mount_type}' missing '${attribute}'!")
        }
      }
    } else {
      $mount_type = 'unmanaged'
    }
  } else {
    $mount_type = 'none'
  }

  # Construct the updated entry details if it's SID specific
  if $sid {
    $sid_upper = $sid
    $sid_lower = downcase($sid)

    $sid_path_partial = regsubst($mount_path,
      $sid_upper_pattern, $sid_upper, 'G')
    $updated_mount_path = regsubst($sid_path_partial,
      $sid_lower_pattern, $sid_lower, 'G')
    $updated_owner = regsubst($file_params['owner'],
      $sid_lower_pattern, $sid_lower, 'G')
    $updated_group = regsubst($file_params['group'],
      $sid_lower_pattern, $sid_lower, 'G')

    # If there are required directories perform the substitution on them as well
    unless(empty($required_files)) {
      $updated_required_files = $required_files.map | $require_entry | {
        $require_pass_1 = regsubst($require_entry,
          $sid_upper_pattern, $sid_upper, 'G')
        regsubst($require_pass_1,
          $sid_lower_pattern, $sid_lower, 'G')
      }
    } else {
      $updated_required_files = []
    }

    # Construct the parameters
    case $mount_type {
      'nfsv4': {
        $updated_share_partial = regsubst($mount_parameters['share'],
          $sid_upper_pattern, $sid_upper, 'G')
        $updated_share = regsubst($updated_share_partial,
          $sid_lower_pattern, $sid_lower, 'G')
      }
      default: {
        notify { "mount_point: '${updated_mount_path}' type '${mount_type}' has no SID specific parameters!": }
      }
    }
  } else {
    $updated_mount_path = $mount_path
    $updated_owner = $file_params['owner']
    $updated_group = $file_params['group']
    $updated_required_files = $required_files

    case $mount_type {
      'nfsv4': {
        $updated_share = $mount_parameters['share']
      }
      default: {
        notify { "mount_point: '${updated_mount_path}' type '${mount_type}' has no parameters!": }
      }
    }
  }

  # Construct the parameters
  case $mount_type {
    'nfsv4': {
      if 'options_nfsv4' in $mount_parameters {
        $mount_options_nfsv4 = $mount_parameters['options_nfsv4']
      } else {
        $mount_options_nfsv4 = $mount_defaults['nfsv4']['options']
      }

      # Build the NFS Mount parameters
      $updated_params = {
        ensure        => 'mounted',
        server        => $mount_parameters['server'],
        share         => $updated_share,
        atboot        => true,
        options_nfsv4 => $mount_options_nfsv4,
        owner         => $updated_owner,
        group         => $updated_group,
        mode          => $file_params['mode'],
      }
      $resource_type = 'nfs::client::mount'
    }
    default: {
      # File based systems 
      $updated_params = {
        ensure => 'directory',
        owner  => $updated_owner,
        group  => $updated_group,
        mode   => $file_params['mode'],
      }
      $resource_type = 'file'
    }
  }

  # Create the directory as specified or create "count" instances
  unless($count) {
    Resource[$resource_type] { $updated_mount_path:
      *      => $updated_params,
    }

    # Dependencies - might be redundant due to autodepend
    $updated_required_files.each | $file | {
      File[$file] -> Resource[$resource_type][$updated_mount_path]
    }
  } else {
    Integer[1, $count].each | $idx | {
      $idx_string = String.new($idx)
      $mount_path_idx = regsubst($updated_mount_path, '_N_', $idx_string, 'G')
      Resource[$resource_type] { $mount_path_idx:
        *      => $updated_params,
      }

      # Count specific dependencies
      $updated_required_files.each | $file | {
        File[$file] -> Resource[$resource_type][$mount_path_idx]
      }
    }
  }
}
