# Used to model linux high availability rules for one or more application server
# instances. 
type Sap::RscAs = Hash[
  Enum[
    'pas',        # Boolean value indicating whether this is a shared host app
    'pas_ip',     # Service IP corresponding to the Primary Application server
    'as_inst',    # Instance details for the AS
  ],
  Variant[
    Stdlib::Host,
    Stdlib::IP::Address::Nosubnet,
    Sap::InstData,
  ],
]
