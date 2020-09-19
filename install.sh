#!/bin/bash
set -e

license=
if [ -n "$NR_LICENSE_KEY" ]; then
    license=$NR_LICENSE_KEY
fi

curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | apt-key add -
echo "license_key: $license" > /etc/newrelic-infra.yml
printf "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt bionic main" > /etc/apt/sources.list.d/newrelic-infra.list
apt-get update
apt-get install newrelic-infra -y
