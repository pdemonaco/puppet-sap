# Simple define to manage the installation of a given package set.
#
# @summary Manages the installation of a package set
#
# @param package_list [Array[String]]
#   An array containing the names of the packages which are to be installed as a
#   part of this set.
#
define sap::install::package_set (
  Array[String] $package_list = []
) {
  unless(empty($package_list)) {
    $package_list.each | $package_name | {
      package { $package_name:
        ensure => installed
      }
    }
  } else {
    warning("No ${title} packages were specified!")
  }
}
