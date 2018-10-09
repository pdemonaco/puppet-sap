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

## Release 0.9.1
* Some changes ?

## Release 0.9.0
* Initial release
