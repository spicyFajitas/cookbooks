# Uptime Kuma Docker Compose

The docker file will set up an Uptime Kuma instance and Cloudflare Tunnel. 

The Cloudflare Tunnel still needs an authentication token, which should be put in the same directory as the docker-compose file in an environment `.env` file. 

After the tunnel is confirmed to be working, you still need to configure the IP, port, hostname, etc. in the cloudflare zero trust dashboard.