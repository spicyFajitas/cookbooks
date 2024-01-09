#!/bin/bash
# used to delete docker virtual interfaces from a server
# pretty aggressive in its deletion

# Get a list of network interfaces with "veth" in their name
interfaces=$(ip link show | grep 'veth' | awk -F': ' '{print $2}' | sed 's/@.*//')

# Iterate over the interfaces and delete them
for interface in $interfaces; do
    echo "Deleting interface: $interface"
    ip link delete "$interface"
done

echo "Deletion complete."