# Uptime Kuma Docker Compose

## Links

- [reference `docker-compose.yml`](https://github.com/TheBestPessimist/cloudflare-tunnel-docker-compose-example)
- [cloudflare zero trust dashboard](https://one.dash.cloudflare.com/)

The docker file will set up an Uptime Kuma instance and Cloudflare Tunnel.

The Cloudflare Tunnel still needs an authentication token, which should be put in the same directory as the docker-compose file in an environment `.env` file.

!!! warning:
    The environment variables cannot be renamed. They have to be named according to their documentation.

After the tunnel is confirmed to be working, you still need to configure the IP, port, hostname, etc. in the cloudflare zero trust dashboard.
