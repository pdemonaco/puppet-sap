# Simple structure containing the type of an instance along with it's instance
# number and the host name of the server on which it must run. This may be a
# virtual host for servers that can run on multiple nodes.
type Sap::InstData = Hash[
  Enum[
    'type',   # Category of SAP instance
    'number', # 2 digit SAP instance number
    'host'    # Hostname or alias for this component
    ],
  Variant[
    Sap::InstType,
    Pattern[/[0-9]{2}/],
    Stdlib::Host,
  ],
]
