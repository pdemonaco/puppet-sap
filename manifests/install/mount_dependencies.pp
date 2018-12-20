# When enabled this ensures that all necessary dependencies for mount point
# management are installed
#
# @summary Installs dependent modules needed for mount points
class sap::install::mount_dependencies {
  # Setup NFSv4 configuration
  class { 'nfs':
    server_enabled      => false,
    client_enabled      => true,
    nfs_v4_client       => true,
    nfs_v4_idmap_domain => $sap::params::config_default_mount_options['nfsv4']['idmap_domain'],
  }
  contain 'nfs'
}
