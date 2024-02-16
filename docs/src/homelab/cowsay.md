# Cowsay

## Overview

MTOD files located at `/etc/update-motd.d`

```
~ ❯ cat /etc/update-motd.d/93-cowsay-inspiration
#!/bin/sh
echo

QUOTE=$(fortune -c | cowsay)

echo "$QUOTE"
```

```bash
# uncomment line below to run motd every login
# run-parts /etc/update-motd.d/
```