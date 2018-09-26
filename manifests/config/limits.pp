# This class uses data from hiera to generate an etc limits file for each
# enabled component. Note that some components do not specify limits while
# others may have SID specific data which will result in a more complicated
# limit output
#
# @summary Generates an etc limits file for each relevant enabled component.
# @author Phil DeMonaco <pdemon@gmail.com>
#
class sap::config::limits {
  $sap::params::config_limits.each | $component, $parameters | {
    if $component in $sap::enabled_components {
      # TODO - add tests to ensure we error gracefully if this stuff is missing
      $path = $parameters['path']
      $sequence = $parameters['sequence']
      $header_comment = $parameters['header_comment']
      $entries = $parameters['entries']

      # If this is an SID specific file create one per SID
      if $parameters['per_sid'] {
        # Replace the SID pattern in the user/group name with the system SID
        $per_sid_array = $sap::system_ids.map | $sid | {
          $transformed_entries = $entries.map | $entry | {
            $base_group = $entry[0]
            $sid_group = regsubst($base_group, '_sid_', $sid, 'G')

            # Return value for the mapping
            $new_entry = [$sid_group, $entry[1]]
          }

          $limits_arguments = {
            'header_comment' => $header_comment,
            'entries'        => $transformed_entries,
          }

          file { "${path}/${sequence}-sap-${component}-${sid}.conf":
            ensure  => file,
            mode    => '0644',
            content => epp($parameters['template'], $limits_arguments),
          }
        }
      } else {
        # Otherwise just create a normal file
        $limits_arguments = {
          'header_comment' => $header_comment,
          'entries'        => $entries,
        }

        file { "${path}/${sequence}-sap-${component}.conf":
          ensure  => file,
          mode    => '0644',
          content => epp($parameters['template'], $limits_arguments),
        }
      }
    }
    # Do nothing for components which aren't enabled
  }
}
