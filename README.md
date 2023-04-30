# Cookbooks

## Table of contents

- Overview
- Requirements
- Installation
- Variables
- Usage
- To Do
- Credits
- Current Maintainers

## Overview

This repo contains all of my homelab cookbooks, from ansible roles and docker-compose files to (shitty) kubernetes manifests and personal userscripts.

## Requirements

## Installation

## Variables

## Usage

## To Do

## Credits

## Support

If you are testing containers and create "development" containers with the default usernames, passwords, and configurations, you will need to completely remove the images once you are ready to create production containers with properly secure usernames, passwords, and configurations.

Run `docker-compose down -v` from the directory your `docker-compose.yml` file is located in to shut down the docker containers and destroy the container data. The volumes outside the container mapped to the host will be safe - don't worry about data loss. Then, run `docker-compose up --build` to rebuild the containers with the proper passwords and configuration.

## Current Maintainers

- [spicyFajitas](https://github.com/spicyFajitas)
