#!/bin/bash
set -e

function info {
    echo -e "\033[1;33m$1\033[0m"
}

function unsupported {
    echo -e "\033[1;31mThis Linux distribution is not supported by this script.\033[0m"
    echo
    echo "The supported distros are:"
    echo "  - Amazon Linux (2, 1)"
    echo "  - Debian (10, 9, 8)"
    echo "  - CentOS (8, 7, 6)"
    echo "  - Red Hat Enterprise Linux (8, 7, 6)"
    echo "  - SUSE Linux Enterprise Server (15, 12, 11)"
    echo "  - Ubuntu (20.04, 18.04, 16.04, 14.04, 12.04)"
    echo
    echo "Create a GitHub issue (https://github.com/fryckbos/infra-install/issues) to request support."
    exit 1
}

function success {
    echo
    echo -e "\033[1;32mSuccessfully installed the New Relic Infra agent!\033[0m"
    echo
    echo "For more information about the agent check out our docs at https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/get-started/install-infrastructure-agent"
}

function error {
    echo
    echo -e "\033[1;31mSomething went wrong during the installation of the agent.\033[0m"
    echo
    echo "For more information see the documentation at"
    echo
    echo "   https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/get-started/install-infrastructure-agent"
    echo
    echo "If that doesn't solve the issue, please contact support@newrelic.com and provide your distribution, version and the output of the script."
}

trap error ERR

function install_apt {
    CODENAME=$1
    if [[ $CODENAME =~ (bionic|xenial|trusty|precise|buster|stretch) ]]; then
        info "Creating the config file with your license key"
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml

        info "Setting up the New Relic Infrastructure Agent gpg key"
        dpkg -s gnupg >/dev/null 2>/dev/null || sudo apt-get update && sudo apt-get install -y gnupg
        curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -

        info "Adding the New Relic Infrastructure Agent apt repo"
        echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list

        info "Updating the apt cache"
        sudo apt-get update

        info "Installing the agent"
        sudo apt-get install newrelic-infra -y
    elif [ "$CODENAME" == "jessie" ]; then
        info "Creating the config file with your license key"
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml

        info "Setting up the New Relic Infrastructure Agent gpg key"
        curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -

        info "Adding the New Relic Infrastructure Agent apt repo"
        echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list

        info "Updating the apt cache"
        sudo apt-get -o Acquire::Check-Valid-Until=false update || echo "Expected failure because of deprecation."

        info "Installing the agent"
        sudo apt-get install newrelic-infra -y
    else
        unsupported
    fi
}

function install_redhat {
    RH_RELEASE=$1
    if [[ $RH_RELEASE =~ ^(5|6|7|8)$ ]]; then
        info "Creating the config file with your license key"
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml

        info "Adding the New Relic Infrastructure Agent yum repo"
        sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/$RH_RELEASE/x86_64/newrelic-infra.repo

        info "Installing the agent"
        sudo yum -y --disablerepo='*' --enablerepo='newrelic-infra' install newrelic-infra
    else
        unsupported
    fi
}

function install_suse {
    SUSE_RELEASE=$1
    if [ $SUSE_RELEASE = "11.4" ]; then
        info "Creating the config file with your license key"
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml

        info "Setting up the New Relic Infrastructure Agent gpg key"
        curl -s -o /tmp/newrelic-infra.gpg https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg && sudo rpm --import /tmp/newrelic-infra.gpg

        info "Adding the New Relic Infrastructure Agent zypper repo"
        sudo curl -o /etc/zypp/repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/zypp/sles/11.4/x86_64/newrelic-infra.repo

        info "Updating the zypper cache"
        sudo zypper -n ref -r newrelic-infra

        info "Installing the agent"
        sudo zypper -n install newrelic-infra
    elif [ $SUSE_RELEASE = "12.4" ]; then
        info "Creating the config file with your license key"
        echo "license_key: $NR_LICENSE_KEY" | sudo tee -a /etc/newrelic-infra.yml

        info "Setting up the New Relic Infrastructure Agent gpg key"
        curl -s -o /tmp/newrelic-infra.gpg https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg && sudo rpm --import /tmp/newrelic-infra.gpg

        info "Adding the New Relic Infrastructure Agent zypper repo"
        sudo curl -o /etc/zypp/repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/zypp/sles/12.4/x86_64/newrelic-infra.repo

        info "Updating the zypper cache"
        sudo zypper -n ref -r newrelic-infra

        info "Installing the agent"
        sudo zypper -n install newrelic-infra
    else
        unsupported
    fi
}

DISTRO=$(cat /etc/issue /etc/system-release /etc/redhat-release /etc/os-release 2>/dev/null | grep -m 1 -Eo "(Ubuntu|Amazon|CentOS|Debian|Red Hat|SUSE)" || true)

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

success
