# Speedtest-Tracker

## Overview

I set up this container to monitor my WAN connection with Spectrum because it's pretty bad. There's frequent drops and I wanted to gather good data in case they question the internet drops we're having when I reach out for support.

## Web Configuration

For some reason, the time zone is ahead. To get it to properly display in Eastern Time Zone, I had to set it to Alaskan time.

Display time zone: `America/Anchorage`

Time format: `M j, Y h:i:s:a`

Speedtest schedule (cron): `*/10 * * * *` (every 10 minutes)
