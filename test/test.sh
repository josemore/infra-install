#!/bin/bash

date
echo "Waiting for cloud-init to complete..."
cloud-init status --wait
echo "Cloud init is done"
date

sudo sh -c 'cat << EOF >> /etc/hosts
127.0.0.1 infrastructure-command-api.newrelic.com
127.0.0.1 identity-api.newrelic.com
127.0.0.1 infra-api.newrelic.com
EOF'

sudo nc -w 1 -l 443 > network.bin &
sleep 180 && echo "QUIT" | nc localhost 443 &

## Run install script here
curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add - && \
echo "license_key: $LICENSE" | sudo tee /etc/newrelic-infra.yml && \
printf "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt bionic main" | sudo tee /etc/apt/sources.list.d/newrelic-infra.list && \
sudo apt-get update && \
sudo apt-get install newrelic-infra -y
## End of install script

fg %1
kill %2

if grep newrelic network.bin; then
    echo "==== Test result \033[0;32m${1}:success\033[0m"
else
    echo "==== Test result \033[0;31m${1}:failure\033[0m"
fi
