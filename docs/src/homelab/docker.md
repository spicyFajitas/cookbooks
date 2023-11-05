# Docker

## Overview

## Bind Port Errors

```
Error response from daemon: driver failed programming external connectivity on endpoint semaphore-postgres-1 (fbe183265d127afc95f0cd4ccb5e7d682fed8770e44d4c9b248f14f3f2d2ef92): Bind for 0.0.0.0:5432 failed: port is already allocated
```

If you are trying to start or restart containers and you receive errors like these, make sure to stop the containers, remove the containers, remove the networks, and then try to restart the containers again.

```
docker compose remove semaphore
docker compose remove postgres 
docker network rm -f semaphore_default
```
