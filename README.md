
# data_entitlement

![](https://img.shields.io/puppetforge/pdk-version/puppetlabs/data_entitlement.svg?style=popout)
![](https://img.shields.io/puppetforge/v/puppetlabs/data_entitlement.svg?style=popout)
![](https://img.shields.io/puppetforge/dt/puppetlabs/data_entitlement.svg?style=popout)
[![Build Status](https://github.com/puppetlabs/puppetlabs-data_entitlement/actions/workflows/pr_test.yml/badge.svg?branch=main)](https://github.com/puppetlabs/puppetlabs-data_entitlement/actions/workflows/pr_test.yml)

This module will help you setup HDP's report processor on a PE Primary or Compiler. It will also help you setup a node to host the HDP application stack.

- [Description](#description)
- [Setup](#setup)
  - [What data_entitlement affects](#what-data_entitlement-affects)
  - [Setup Requirements](#setup-requirements)
- [Usage](#usage)
- [Reference](#reference)
- [Changelog](#changelog)

## Description

There are two parts to getting started with HDP:

1. Setting up a node to run HDP itself (`data_entitlement::app_stack`)
2. Configuring your PE Master and any Compilers to send data to HDP (`data_entitlement::report_processor`)

## Setup

### What data_entitlement affects

This module will modify the puppet.conf configuration of any master or compiler that it is applied to. Additionally, it will install and configure Docker on the node running HDP.

### Setup Requirements

HDP only works with Puppet Enterprise.

## Usage

See [REFERENCE.md](REFERENCE.md) for example usage.

## Reference

A custom fact named `data_entitlement-health` is included as part of this module. It is a structured fact that returns information about the currently running instance of HDP.
Also, if this module is installed on a node, an `data_entitlement` fact is included that will collect unmanaged resource information, but not land in PuppetDB.

This module is documented via `pdk bundle exec puppet strings generate --format markdown`. Please see [REFERENCE.md](REFERENCE.md) for more info.

## Releases

To release a new version of the module, run the Auto release Github
Action. It will generate new documentation, update the changelogs, and bump the
version based on the labels on the PRs included in the release. It will open a
PR, which should be reviewed and merged.

Once the release prep has been merged to the main branch, run the Publish
module action to tag the release and release it to the Forge.

## Changelog

[CHANGELOG.md](CHANGELOG.md) is generated prior to each release via `pdk bundle exec rake changelog`. This process relies on labels that are applied to each pull request.
