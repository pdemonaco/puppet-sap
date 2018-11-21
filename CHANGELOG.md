# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.0

**Features**
* Major rework to use hiera data far more heavily than static config
* Removal of legacy 3.x syntax (e.g. `::sap`
* Refactor to support other architectures, ppc64 in particular
* Addition of dynamically calculated limits and sysctl entries
* Updated to match the latest RHEL 7 guidelines from SAP
* Added notify check for swap partition size
* Added validation and update of /dev/shm size
* Added test to ensure an SID is specified
* Added management of default mount point creation for 'base' and 'db2' components
* Added a top-level configuration of SID string replacement patterns
* Added support for managing NFS mounts 
* Includes required packages for db2 10.5

**Bugfixes**
* Expanded the yum groups to actual package names to avoid constant service restarts
* Corrected the root cause of the restarts by specifying the uuidd.socket service instead of just uuidd.service. This is due to systemctl shenanigans as described in [PUP-6759](https://tickets.puppetlabs.com/browse/PUP-6759)

## Release 0.9.1
* Some changes ?

## Release 0.9.0
* Initial release
