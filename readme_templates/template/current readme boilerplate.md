# Current Readme Boilerplate

## Table of contents

- [Overview](#overview)
- [Known Issues](#known-issues)
- [Software](#software)
- [Requirements](#requirements)
- [Installation](#installation)
- [Variables](#variables)
- [Common Tasks](#common-tasks)
- [Usage](#usage)
- [To Do](#to-do)
- [Resources](#resources)
- [Disaster Recovery](#disaster-recovery)
- [Rollback Instructions](#rollback-instructions)
- [Failover](#failover)
- [Recreate](#recreate)
- [Credits](#credits)
- [Current Maintainers](#current-maintainers)

## Overview

This is summary. It explains in high level detailg about your project and what it's functions are. More details are explained below in the the various sections.

### Known Issues

## Software

Notes about software that is set up on server

## Requirements

- Working Cloudflare API token
- Domain managed through Cloudflare Nameservers

## Installation

To create a CloudFlare API token for your DNS zone go to the [cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) and follow these steps:

- Click Create Token
- Provide the token a name, for example, cloudflare-ddns
- Grant the token the following permissions:
- Zone - Zone Settings - Read
- Zone - Zone - Read
- Zone - DNS - Edit
- Set the zone resources to:
- Include - All zones
- Complete the wizard and copy the generated token into the API_KEY variable for the container

The steps were copied from oznu/cloudflare's [docker hub page](https://hub.docker.com/r/oznu/cloudflare-ddns/) and [githubpage](https://github.com/oznu/docker-cloudflare-ddns).

## Variables

## Common Tasks

Notes about procedures that need to be done on servers. These are not every day tasks but they do need to be done every so often.

## Usage

In the `docker-compose.yml` file, set the `CF_API_TOKEN=<PASTE_API_KEY_HERE>` variable as the API key you just created. Then, you will want to configure your domains and subdomains through the two services `DOMAINS=subdomain.domain.com` variables.

## To Do

## Resources

## Disaster Recovery

### Rollback Instructions

### Failover

### Recreate

## Credits

Big thanks to [favonia](https://github.com/favonia/cloudflare-ddns) and [oznu (github)](https://github.com/oznu/docker-cloudflare-ddns) / [oznu (docker hub)](https://hub.docker.com/r/oznu/cloudflare-ddns/)

Much of the docker compose files is drawn directly from these sources.

## Current Maintainers

- [spicyFajitas](https://github.com/spicyFajitas)
