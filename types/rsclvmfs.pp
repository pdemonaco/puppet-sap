# Parameters for a filesystem resource which is assumed to be LVM backed.
# vgname and lvname are used to construct the device path.
# This artificially restricts vg and lv names to [a-zA-Z0-9_]{2,} for 
# simplification purposes.
type Sap::RscLvmFs = Hash[
  Enum[
    'directory',  # Absolute path to the FS mount point
    'fstype',     # Filesystem type
    'vgname',     # Volume group containing this FS's logical volume
    'lvname',     # Logical volume containing this FS
  ],
  Variant[
    Stdlib::Absolutepath,
    Enum['ext4', 'xfs'],
    Pattern[/[a-zA-Z0-9_]{2,}/],
  ],
]
