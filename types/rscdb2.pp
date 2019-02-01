# Used to model linux high availability rules for a HADR based DB2 cluster
# Note that this assumes a single SID per instance. (SAP typically assumes this
# too!)
type Sap::RscDb2 = Hash[
  Enum[
    'db_ip',        # Service IP corresponding to the database cluster
    'database',     # Name of the database to be automated.
    'filesystems',  # Array of filesystem resources colocated w/ the master
  ],
  Variant[
    Stdlib::IP::Address::Nosubnet,
    Sap::SID,
    Array[Sap::RscLvmFs],
  ],
]
