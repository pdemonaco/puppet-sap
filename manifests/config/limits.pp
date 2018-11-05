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
      $per_sid = $parameters['per_sid']

      # If this is an SID specific file we need to transform our input structure
      # using the SID pattern
      if $per_sid {
        # Retrieve target pattern
        case $parameters['sid_pattern'] {
          'upper': {
            $sid_pattern = $sap::params::config_sid_upper_pattern
          }
          'lower': {
            $sid_pattern = $sap::params::config_sid_lower_pattern
          }
          default: {
            $sid_pattern = $sap::params::config_sid_lower_pattern
          }
        }

        # Replace the SID pattern in the user/group name with the system SID
        # TODO - maybe only do this for keys which match the pattern?
        $entries_transformed = $entries.map | $entry | {
          $base_group = $entry[0]
          $data = $entry[1]

          # Create a new pair per entry
          $per_sid_array = $sap::system_ids.map | $sid | {
            $sid_group = regsubst($base_group, $sid_pattern, downcase($sid), 'G')

            # Return value for the mapping
            $new_entry = [$sid_group, $data]
          }
        }

        $limits_arguments = {
          'header_comment' => $header_comment,
          'entries'        => Hash.new(flatten($entries_transformed)),
        }
      } else {
        # Otherwise just create a normal file
        $limits_arguments = {
          'header_comment' => $header_comment,
          'entries'        => $entries,
        }
      }

      file { "${path}/${sequence}-sap-${component}.conf":
        ensure  => file,
        mode    => '0644',
        content => epp($parameters['template'], $limits_arguments),
      }
    }
    # Do nothing for components which aren't enabled
  }
}
