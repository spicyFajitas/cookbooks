#!/usr/bin/env bash
# One-time migration: merges the 11 old per-service vault files into the new
# roles/docker_services/vaults/production.yml, namespaced per service so
# that vars re-used across services (base_domain, discord_webhook,
# cf_tunnel_api) with *different* actual values per service can't collide.
#
# Run this yourself from the ansible/ directory -- it never prints anything
# to your terminal, and no plaintext ever leaves your machine.
#
#   cd ansible && ./migrate-docker-vaults.sh
#
# Afterwards:
#   ansible-vault view --vault-password-file vault-pass.txt \
#     roles/docker_services/vaults/production.yml
#   -- confirm all 11 services and their keys look right, THEN delete the
#   old roles/{frigate,grafana,homepage,mealie,media,minecraft-docker,
#   netbox,netdata,speedtest-tracker,uptime_kuma,wyze}/ directories.
#
# Safe to re-run: it only ever reads the old vault files and writes a fresh
# copy of the new one; nothing is deleted.

set -euo pipefail

SERVICES=(frigate grafana homepage mealie media minecraft-docker netbox netdata speedtest-tracker uptime_kuma wyze)
VAULT_PASS="vault-pass.txt"
OUT="roles/docker_services/vaults/production.yml"

if [[ ! -f "$VAULT_PASS" ]]; then
  echo "error: $VAULT_PASS not found -- run this from the ansible/ directory" >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

{
  echo "---"
  echo "docker_services_secrets:"
  for svc in "${SERVICES[@]}"; do
    src="roles/${svc}/vaults/production.yml"
    if [[ ! -f "$src" ]]; then
      echo "error: $src not found" >&2
      exit 1
    fi
    echo "  ${svc}:"
    ansible-vault view --vault-password-file "$VAULT_PASS" "$src" \
      | grep -v '^---$' \
      | sed 's/^/    /'
  done
} > "$TMP"

ansible-vault encrypt --vault-password-file "$VAULT_PASS" --output "$OUT" "$TMP"

echo "Wrote $OUT"
echo "Verify with: ansible-vault view --vault-password-file $VAULT_PASS $OUT"
