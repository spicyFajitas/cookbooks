#!/bin/bash

TIMEOUT=0
CLEAN=0

function usage() {
    echo "Usage: $0 [-t <timeout>]"
    echo "-t <timeout> - specify a timeout after which the preview server will be stopped"
    echo "-c - clean the build directory before generating the preview"
    exit 1
}

function main() {
    if [ $CLEAN -eq 1 ]; then
        ./env/bin/mkdocs build --clean
    fi
    echo -e "\nStarting preview server. To shutdown the preview server when you are done, hit CTRL+C\n"
    if [ $TIMEOUT -gt 0 ]; then
        timeout --preserve-status $TIMEOUT ./env/bin/mkdocs serve --dirtyreload
    else
        ./env/bin/mkdocs serve --dirtyreload
    fi
}

while getopts "t:c" opt 2>/dev/null; do
    case $opt in
    t) TIMEOUT=$OPTARG ;;
    c) CLEAN=1 ;;
    *) usage ;;
    esac
done

main
