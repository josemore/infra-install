#!/bin/bash
set -m # Enable job control (fg)

echo "Waiting for cloud-init to complete."
cloud-init status --wait 2>/dev/null

which nc >/dev/null || sudo yum install nc -y || (sudo apt-get update && sudo apt-get install -y netcat-openbsd) || sudo rpm -i --force http://plug-mirror.rcac.purdue.edu/opensuse/repositories/network%3A/utilities/SLE_11_SP4/x86_64/netcat-openbsd-1.89-108.1.x86_64.rpm
[ "$(lsb_release -sc 2>/dev/null)" == "jessie" ] && sudo apt-get -o Acquire::Check-Valid-Until=false update && sudo apt-get install -y netcat-openbsd curl

sudo sh -c 'cat << EOF >> /etc/hosts
127.0.0.1 infrastructure-command-api.newrelic.com
127.0.0.1 identity-api.newrelic.com
127.0.0.1 infra-api.newrelic.com
EOF'

sudo nc -w 1 -l 443 > network.bin &
sleep 180 && echo "QUIT" | nc localhost 443 &

NR_LICENSE_KEY=012345678901234567890123456789012345NRAL bash -c "$(curl -L https://raw.githubusercontent.com/fryckbos/infra-install/master/install.sh)"

fg %1
kill %2

if grep newrelic network.bin; then
    echo "==== Test result \033[0;32m${1}:success\033[0m"
else
    echo "==== Test result \033[0;31m${1}:failure\033[0m"
fi
