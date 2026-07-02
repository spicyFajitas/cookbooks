# GitHub Actions Runner

## Overview

Registers this host as a self-hosted GitHub Actions runner for
`spicyFajitas/cookbooks`, using the `myoung34/docker-github-actions-runner`
image so the pattern matches every other service in this repo (templated
`docker-compose.yml`, idempotent restart on change). The container itself
talks to the GitHub API on startup to mint a fresh, short-lived registration
token from the long-lived personal access token in `vaults/production.yml`
-- restarting the container re-registers cleanly, no manual token juggling.

This runner is what lets `.github/workflows/*.yml` reach the private LAN
(10.100.10.x) -- GitHub-hosted runners can't route there. Workflows that
need Proxmox/LAN access target it via `runs-on: [self-hosted, homelab]`.

## Requirements

- A GitHub personal access token with `repo` scope (classic PAT, or a
  fine-grained PAT with Administration: read/write on this repo), stored as
  `github_actions_runner_access_token` in `vaults/production.yml`.
- Docker already present on the host (this repo installs Docker via the
  Packer golden image, not via Ansible -- see `packer/ubuntu-server-jammy-docker.pkr.hcl`).

## Dependencies

- helper/ssh
- helper/packages
- helper/timezone
