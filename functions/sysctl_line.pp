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
