#!/bin/bash
set -e

function unsupported {
    echo "Unsupported distro."
}

function install_ubuntu {
    RELEASE=$1
    curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
    echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
    echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $RELEASE main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list
    sudo apt-get update
    sudo apt-get install newrelic-infra -y
}

function install_amazon {
    RH_RELEASE=$1
    echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml &&
    sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/$RH_RELEASE/x86_64/newrelic-infra.repo
    sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
    sudo yum install newrelic-infra -y
}

DISTRO=$(cat /etc/issue /etc/system-release | grep -m 1 -Eo "(Ubuntu|Amazon)" 2>/dev/null)

if [ "$DISTRO" == "Ubuntu" ]; then
    RELEASE=$(lsb_release -sc)

    if [[ $RELEASE == "focal" ]]; then
        RELEASE="bionic"
    fi

    if [[ $RELEASE =~ (bionic|xenial|trusty|precise) ]]; then
        install_ubuntu $RELEASE
    else
        unsupported && exit 1
    fi
elif [ "$DISTRO" == "Amazon" ]; then
    if [[ $(cat /etc/system-release) =~ " release 2 " ]]; then
        install_amazon 7
    else
        install_amazon 6
    fi
else
    unsupported && exit 1
fi
