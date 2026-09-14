#!/bin/bash

set -e

# always operate relative to docs/, regardless of where this script is invoked from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

if ! command -v python3 > /dev/null 2>&1; then
    echo "python3 not found. Install it first:"
    echo "  macOS:  brew install python3"
    echo "  Ubuntu: sudo apt-get install python3"
    exit 1
fi

echo "creating venv..."
if ! python3 -m venv env; then
    echo "Failed to create a virtual environment."
    echo "  Ubuntu: sudo apt-get install python3-venv"
    echo "  macOS:  brew reinstall python3"
    exit 1
fi

echo "upgrading pip inside venv..."
./env/bin/python3 -m pip install --upgrade pip > /dev/null

echo "installing pip dependencies..."
./env/bin/python3 -m pip install --upgrade -r requirements.txt

echo "done. run ./bin/preview.sh to start the preview server."
