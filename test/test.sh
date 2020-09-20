#!/bin/bash
set -m # Enable job control (fg)

which nc || sudo yum install nc -y

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
