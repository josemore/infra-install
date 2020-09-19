#!/bin/bash
set -e

function unsupported {
    echo "Unsupported distro."
}

function install_ubuntu {
    RELEASE=$1
    curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
    echo "license_key: $NR_LICENSE_KEY" | sudo tee /etc/newrelic-infra.yml
    echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $RELEASE main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list
    sudo apt-get update
    sudo apt-get install newrelic-infra -y
}

DISTRO=$(cat /etc/issue | grep -Eo "(Ubuntu)" 2>/dev/null)

if [ "$DISTRO" == "Ubuntu" ]; then
    RELEASE=$(lsb_release -sc)

    if [[ $RELEASE == "focal" ]]; then
        $RELEASE="bionic"
    fi

    if [[ $RELEASE =~ (bionic|xenial|trusty|precise) ]]; then
        install_ubuntu $RELEASE
    else
        unsupported && exit 1
    fi
else
    unsupported && exit 1
fi
