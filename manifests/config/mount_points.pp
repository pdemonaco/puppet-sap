# Creates and manages mountpoints relevant to each instance type.
class sap::config::mount_points {
  $mount_components = $sap::enabled_components + ['common']
  $sap::mount_points.each | $component, $mpaths | {
    if $component in $mount_components {
      # Configure the paths for each enabled component
      $mpaths.each | $base_path, $parameters | {

        # Validate the mountpoint definition
        unless('per_sid' in $parameters) {
          fail("mount_point: '${component}' path '${base_path}' missing 'per_sid'!")
        }

        # Ensure file parameters were specified - this is mandatory
        unless('file_params' in $parameters) {
          fail("mount_point: '${component}' path '${base_path}' missing 'file_params'!")
        } else {
          $base_file_params = $parameters['file_params']
        }

        # Required files is optional
        if 'required_files' in $parameters {
          $base_required_files = $parameters['required_files']
        } else {
          $base_required_files = []
        }

        # Count is optional
        if 'count' in $parameters {
          $base_count = $parameters['count']
        } else {
          $base_count = undef
        }

        # Some entities created by this process aren't mountpoints
        if 'mount_params' in $parameters {
          $base_mount_params = $parameters['mount_params']
        } else {
          $base_mount_params = {}
        }

        # Per SID entries have the upper and lower case versions of the SID
        # substituted into the path and into the user and group names. 
        if $parameters['per_sid'] {
          # Iterate through each SID 
          $sap::system_ids.each | $sid | {

            # Assemble the argument to the defined type
            sap::config::mount_point { "${base_path}_${sid}":
              mount_path       => $base_path,
              file_params      => $base_file_params,
              sid              => $sid,
              count            => $base_count,
              mount_parameters => $base_mount_params,
              required_files   => $base_required_files,
            }
          }
        } else {
          sap::config::mount_point { $base_path:
            file_params      => $base_file_params,
            count            => $base_count,
            mount_parameters => $base_mount_params,
            required_files   => $base_required_files,
          }
        }
      }
    }
  }
}
