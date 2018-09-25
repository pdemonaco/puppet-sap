function sap::sysctl_calculated_values(
  Array[Hash] $data,
  Integer $index
) >> String {
  $func_name = 'sap::sysctl_calculated_value'

  # Recurse until we reach the base case
  if $index < length($data) - 1 {
    $previous = sap::sysctl_calculated_values($data, $index + 1)
  } else {
    $previous = undef
  }

  $data_entry = $data[$index]

  # Determine the calc_type
  if 'calc_type' in $data_entry {
    $calc_type = $data_entry['calc_type']
  } else {
    fail("${func_name}: a 'calc_type' must be specified! (Index ${index})")
  }

  # Valid calc_types are 'value' and 'calculated'
  case $calc_type {
    'value': {
      $value = $data_entry['value']
    }
    'calculated': {
      if 'base' in $data_entry {
        $base = $data_entry['base']
      } else {
        fail("${func_name}: a 'base' value must be set! (Index ${index})")
      }

      # Multiplier defaults to 1
      if 'multiplier' in $data_entry {
        $multiplier = $data_entry['multiplier']
      } else {
        $multiplier = 1
      }

      # Divisor defaults to 1
      if 'divisor' in $data_entry {
        $divisor = $data_entry['divisor']
      } else {
        $divisor = 1
      }

      $value = $base * $multiplier / $divisor
    }
    default: {
      fail("${func_name}: Unknown 'calc_type' '${calc_type}'! (Index ${index})")
    }
  }

  # Assemble the output
  if $previous {
    $output = " ${value}${previous}"
  } else {
    $output = " ${value}"
  }
}
