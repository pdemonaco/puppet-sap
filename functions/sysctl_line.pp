# This function converts a given entry from a module specific hash provided to
# sap::params::config_sysctl into a line of the form <directive> = <value>.
# There are three supported line types for this component:
# 1. `value` - Simply sets the value equal to the entry name
# 2. `calculated` - Computes the value via the following formula `base * multiplier / divisor`
# 3. `compound` - Performs a recursive call converting multiple value/calculated sub entries into a single space separated value.
#
# @summary This function converts a sysctl entry hash into a string line.
#
# @param param [String]
#   The name of the kernel parameter this corresponds to. E.g. `kernel.sem` is
#   the parameter for Linux kernel Semaphore parameters.
#
# @param data [Hash]
#   Detailed structure containing the components needed to produce the value for
#   the given parameter.
#
# @return [String]
#   A string of the form <directive> = <value>. For example:
#   `kernel.sem = 1250 256000 100 8192`
#
function sap::sysctl_line(
  String $param,
  Hash[
    String,
    Variant[
      String,
      Integer,
      Array[
        Variant[
          String,
          Hash[
            String,
            Variant[
              Integer,
              String,
            ]
          ]
        ]
      ]
    ]
  ] $data
) >> String {
  $func_name = 'sap::sysctl_line'

  # Determine the entry type
  if 'calc_type' in $data {
    $calc_type = $data['calc_type']
  } else {
    fail("${func_name}: '${param}' missing 'calc_type' entry!")
  }

  case $calc_type {
    'compound': {
      if 'content' in $data {
        $value = sap::sysctl_calculated_values($data['content'], 0)
      } else {
        fail("${func_name}: '${param}' 'compound' calc_type must specify 'content'!")
      }
    }
    'value': {
      $value = sap::sysctl_calculated_values([$data], 0)
    }
    'calculated': {
      $value = sap::sysctl_calculated_values([$data], 0)
    }
    default: {
      fail("${func_name}: '${param}' invalid 'calc_type' '${calc_type}'!")
    }
  }
  $line = "${param} =${value}"
}
