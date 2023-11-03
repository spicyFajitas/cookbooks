#!/bin/bash

APT_UPDATE_PERIOD=604800 # how long to wait between apt-get updates (1-week)
NOW=$(date +%s)
APT_LAST_UPDATED=$(stat -c %Y /var/lib/apt/periodic/update-success-stamp)
BAD_EXIT_CODES=0

## checks if a dependency is present and if not installs it
# $1 package name to check
# $2 string to print if package cannot be installed
function install_dep() {
    package=$1
    message=$2
    dpkg -p $package > /dev/null 2>&1
    if [ $? -ne 0 ]; then
    # run apt-get update first if it has been awhile
    let diff=$NOW-$APT_LAST_UPDATED
    if [ $diff -gt $APT_UPDATE_PERIOD ]; then
        sudo apt-get update
        APT_LAST_UPDATED=$(stat -c %Y /var/lib/apt/periodic/update-success-stamp)
    fi

    # install the package
    export DEBIAN_FRONTEND=noninteractive
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y $package
    if [ $? -ne 0 ]; then
        echo "Error installing $package, aborting"
        echo "$message"
        exit 1
    fi
    fi
}

echo "checking apt dependencies..."
install_dep python3-pip "python3-pip not found, please install via 'apt-get install python3-pip'"
install_dep python3-venv "python3-venv not found, please install via 'apt-get install python3-venv'"
install_dep ruby "ruby not found, please install via 'apt-get install ruby'"
if [ ! -d /usr/local/arcanist ]; then
    install_dep arcanist "arcanist not found, please install via 'apt-get install arcanist'"
fi

# TODO: Thiis should probably be offloaded to a Gemfile and bundler.
# when you make changes here, also update roles/drydock-almanac-host/tasks/main.yml in rAP
echo "installing markdownlint"
gem list | grep -q ^mdl
if [ $? -ne 0 ]; then
    # explicitly install dependencies whose newer versions have failures
    gem install --user chef-utils -v 16.6.14
    gem install --user mdl -v 0.11.0
    let BAD_EXIT_CODES=$BAD_EXIT_CODES+$?
fi

echo "upgrading pip outside venv..."
python3 -m pip install --upgrade pip > /dev/null
let BAD_EXIT_CODES=$BAD_EXIT_CODES+$?

echo "creating venv..."
python3 -m venv env > /dev/null
let BAD_EXIT_CODES=$BAD_EXIT_CODES+$?

echo "upgrading pip inside venv..."
./env/bin/python3 -m pip install --upgrade pip > /dev/null
let BAD_EXIT_CODES=$BAD_EXIT_CODES+$?

echo "installing pip dependencies..."
./env/bin/python3 -m pip install --upgrade -r requirements.txt > /dev/null
let BAD_EXIT_CODES=$BAD_EXIT_CODES+$?

if [ $BAD_EXIT_CODES -gt 0 ]; then
    echo "$BAD_EXIT_CODES errors were encountered; please review the output above and re-run"
    exit $BAD_EXIT_CODES
fi
