# Syncthing

## TrueNAS Setup

User and Group Configuration
User ID 568
Group ID 568

Syncthing Config Storage: 
- Host Path `/mnt/Habanero/Syncthing`

Additional Storage: 
- Mount Path `/mount/Habanero`
- Host Path `/mnt/Habanero`

Resource Limits
- CPU `1000m` (1000 millicores = 1 core)
- Memory `4Gi`

Modify dataset ACL to allow user modify access recursively

## Syncthing Setup

Actions > Settings > GUI > Username and Password > Enable HTTPS

