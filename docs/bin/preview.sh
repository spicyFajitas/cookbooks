#!/bin/bash

# always operate relative to docs/, regardless of where this script is invoked from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# mkdocs.yml lives at the repo root, one level up from docs/
CONFIG_FILE="../mkdocs.yml"

TIMEOUT=0
CLEAN=0

function usage() {
    echo "Usage: $0 [-t <timeout>] [-c]"
    echo "-t <timeout> - specify a timeout after which the preview server will be stopped"
    echo "-c - clean the build directory before generating the preview"
    exit 1
}

function main() {
    if [ "$CLEAN" -eq 1 ]; then
        ./env/bin/mkdocs build --clean -f "$CONFIG_FILE"
    fi
    echo -e "\nStarting preview server. To shutdown the preview server when you are done, hit CTRL+C\n"
    if [ "$TIMEOUT" -gt 0 ]; then
        # no reliance on GNU coreutils' `timeout` (absent by default on macOS) -
        # use a background watchdog process instead
        ./env/bin/mkdocs serve --dirtyreload -f "$CONFIG_FILE" &
        server_pid=$!
        (sleep "$TIMEOUT" && kill "$server_pid" 2> /dev/null) &
        watchdog_pid=$!
        wait "$server_pid" 2> /dev/null
        kill "$watchdog_pid" 2> /dev/null
    else
        ./env/bin/mkdocs serve --dirtyreload -f "$CONFIG_FILE"
    fi
}

while getopts "t:c" opt 2> /dev/null; do
    case $opt in
    t) TIMEOUT=$OPTARG ;;
    c) CLEAN=1 ;;
    *) usage ;;
    esac
done

main
