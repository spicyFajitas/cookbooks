# files/

Static assets copied as-is (not run through Jinja) -- as opposed to
`templates/`, which is Jinja-processed `.j2` files.

- `edhrec-grafana-dashboard.json` -- the magic app's (spicyFajitas/magic)
  pre-built EDHRec dashboard, copied from that repo's
  `monitoring/grafana/provisioning/dashboards/edhrec.json`. Not
  auto-provisioned here (the homelab `grafana` service doesn't mount a
  dashboard-provisioning directory) -- import it manually: Grafana ->
  Dashboards -> New -> Import -> upload this file, pick the existing
  Prometheus datasource when prompted. Re-copy from the magic repo if it's
  updated there.
