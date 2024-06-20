# Bash

Sometimes it is useful to iterate over directories and apply a command to all of the directories. With the below example, you can iterate over the docker folders and stop all containers.

```bash
for i in /opt/*; do echo "Processing $i"; cd $i && docker compose down; done
```