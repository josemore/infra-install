#!/bin/bash
set -e

function unsupported {
    echo "Unsupported distro."
    exit 1
}

function install_apt {
    CODENAME=$1
    if [[ $CODENAME =~ (bionic|xenial|trusty|precise|buster|stretch) ]]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        dpkg -s gnupg >/dev/null 2>/dev/null || sudo apt-get update && sudo apt-get install -y gnupg
        curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
        echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list
        sudo apt-get update
        sudo apt-get install newrelic-infra -y
    elif [ "$CODENAME" == "jessie" ]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
        echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list
        sudo apt-get -o Acquire::Check-Valid-Until=false update || echo "Expected failure because of deprecation."
        sudo apt-get install newrelic-infra -y
    else
        unsupported
    fi
}

function install_redhat {
    RH_RELEASE=$1
    if [[ $RH_RELEASE =~ ^(5|6|7|8)$ ]]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/$RH_RELEASE/x86_64/newrelic-infra.repo
        sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
        sudo yum install newrelic-infra -y
    else
        unsupported
    fi
}

function install_suse {
    SUSE_RELEASE=$1
    if [ $SUSE_RELEASE = "11.4" ]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        curl -s -o /tmp/newrelic-infra.gpg https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg && sudo rpm --import /tmp/newrelic-infra.gpg
        sudo curl -o /etc/zypp/repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/zypp/sles/11.4/x86_64/newrelic-infra.repo
        sudo zypper -n ref -r newrelic-infra
        sudo zypper -n install newrelic-infra
    elif [ $SUSE_RELEASE = "12.4" ]; then
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml
        curl -s -o /tmp/newrelic-infra.gpg https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg && sudo rpm --import /tmp/newrelic-infra.gpg
        sudo curl -o /etc/zypp/repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/zypp/sles/12.4/x86_64/newrelic-infra.repo
        sudo zypper -n ref -r newrelic-infra
        sudo zypper -n install newrelic-infra
    else
        unsupported
    fi
}

DISTRO=$(cat /etc/issue /etc/system-release /etc/redhat-release /etc/os-release 2>/dev/null | grep -m 1 -Eo "(Ubuntu|Amazon|CentOS|Debian|Red Hat|SUSE)")

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

elif [ "$DISTRO" == "CentOS" ] || [ "$DISTRO" == "Red Hat" ]; then
    if [ -e /etc/os-release ]; then
        source /etc/os-release
        RELEASE=$(echo $REDHAT_SUPPORT_PRODUCT_VERSION | awk -F. '{ print $1; }')
    elif [[ "$(cat /etc/redhat-release)" =~ "release 6" ]]; then
        RELEASE=6
    fi
    install_redhat $RELEASE

elif [ "$DISTRO" == "SUSE" ]; then
    if [[ $(cat /etc/os-release | grep VERSION ) =~ 11 ]]; then
        install_suse 11.4
    elif [[ $(cat /etc/os-release | grep VERSION ) =~ (12|15) ]]; then
        install_suse 12.4
    fi
else
    unsupported
fi
