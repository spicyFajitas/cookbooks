# Grafana / Prometheus

## Deleting Time Series Data

If you have old nodes that you renamed or no longer want to collect data from, and you want to delete their historical metrics, you can query the admin API to delete the data.

In the docker-compose.yml file, add this flag to the prometheus container `command` section: `- '--web.enable-admin-api'`. Then, send a POST request to the prom server:

```bash
curl -u admin -X POST -g 'http://<<IP_of_prometheus_server>>:9090/api/v1/admin/tsdb/delete_series?match[]={job="<<job_name>>"}'
```
