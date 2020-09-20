#!/bin/bash
set -e

function unsupported {
    echo "Unsupported distro."
    exit 1
}

function install_apt {
    CODENAME=$1
    if [[ $CODENAME =~ (bionic|xenial|trusty|precise|buster|stretch|jessie) ]]; then
        dpkg -s gnupg >/dev/null 2>/dev/null || sudo apt-get update && sudo apt-get install -y gnupg
        curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list
        sudo apt-get update
        sudo apt-get install newrelic-infra -y
    else
        unsupported
    fi
}

function install_redhat {
    RH_RELEASE=$1
    if [[ $RH_RELEASE =~ ^(5|6|7|8)$ ]]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml &&
        sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/$RH_RELEASE/x86_64/newrelic-infra.repo
        sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
        sudo yum install newrelic-infra -y
    else
        unsupported
    fi
}

DISTRO=$(cat /etc/issue /etc/system-release /etc/redhat-release 2>/dev/null | grep -m 1 -Eo "(Ubuntu|Amazon|CentOS|Debian)")

if [ "$DISTRO" == "Ubuntu" ] || [ "$DISTRO" == "Debian" ]; then
    RELEASE=$(lsb_release -sc)

    if [[ $RELEASE == "focal" ]]; then
        RELEASE="bionic"
    fi

    install_apt $RELEASE

elif [ "$DISTRO" == "Amazon" ]; then
    if [[ $(cat /etc/system-release) =~ " release 2 " ]]; then
        install_redhat 7
    else
        install_redhat 6
    fi

elif [ "$DISTRO" == "CentOS" ]; then
    source /etc/os-release
    install_redhat $REDHAT_SUPPORT_PRODUCT_VERSION

else
    unsupported
fi
