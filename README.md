# Sap

[![Build Status](https://travis-ci.org/thbe/puppet-sap.png?branch=master)](https://travis-ci.org/thbe/puppet-sap)
[![Puppet Forge](https://img.shields.io/puppetforge/v/thbe/sap.svg)](https://forge.puppetlabs.com/thbe/sap)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sap](#setup)
    * [What sap affects](#what-sap-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sap](#beginning-with-sap)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)
8. [Contributors](#contributors)


## Overview

The sap module provides packages, settings and other requirements for installing
specific SAP products on this node.

## Module Description

This module takes care that the SAP recommendations for installing specific SAP
products on the Linux operating system are fulfilled on the current node. The
configuration is based on the corresponding SAP OSS notes describing the necessary
steps.

**Keep in mind, this module is _not_ related in any way to official SAP software
distribution nor is it supported in any way by official SAP contracts. This is
my private module to speed up the installation of SAP software in a controlled
puppetized way, so absolutely no warranty at all!**


## Setup

### What sap affects

* local packages
* local configuration files
* local service configurations

### Beginning with sap

There are two mandatory parameters for the environment:
* `enabled_components` - An array of target components that are enabled on this host. 
* `system_ids` - An array of the SIDs which will be present on this machine

The following declaration will enable baseline packages for an SAP instance named 'PR0':

```puppet
class { 'sap':
  system_ids         => ['PR0'],
  enabled_components => [
    'base',
  ],
}
```

Alternatively these values can also be set in hiera:

```yaml
---
sap::system_ids:
  - 'PR0'

sap::enabled_components
  - 'base'
```

## Usage

All interaction with the sap module should be done through the main sap class.
This means you can simply toggle the options in the sap class to get at the full
functionality.

### I just want sap, what's the minimum I need

Declare your SID(s) and the 'base' component in hiera:

```yaml
sap::system_ids
  - 'PR0'

sap::enabled_components
  - 'base'
```

Within your manifest include the SAP profile.

```puppet
include 'sap'
```

### I just want ABAP stack, JAVA stack and ADS on target node.

This example configures the total pre-requisite stack for ADS.

```puppet
class { '::sap':
  system_ids         => ['AP0'],
  enabled_components => [
    'base',
    'base_extended',
    'ads'
  ]
}
```

## Limitations

This module has been built on and tested against Puppet 5.5 and higher.

The module has been tested on:

* RedHat Enterprise Linux 7

but should work on:

* CentOS 6/7
* Oracle Enterprise Linux 6/7
* Scientific Linux 6/7

Testing on other platforms has been light and cannot be guaranteed.

## Development

If you like to add or improve this module, feel free to fork the module and send
me a merge request with the modification.

## Contributors

Check out the [contributor list](https://github.com/thbe/puppet-sap/graphs/contributors).
