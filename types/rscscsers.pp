# Used to model linux high availability rules for an (A)SCS/ERS pair
type Sap::RscScsErs = Hash[
  Enum[
    'ers_ip',     # Service IP corresponding to the ERS
    'ers_inst',   # Instance details for the ERS
    'scs_ip',     # Service IP corresponding to the (A)SCS
    'scs_inst',   # Instance details for the (A)SCS
  ],
  Variant[
    Stdlib::IP::Address::Nosubnet,
    Sap::InstData,
  ],
]
