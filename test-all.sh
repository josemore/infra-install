#!/bin/bash

if [ "$1" == "--help" ]; then
    echo "Test the Infra Linux install script on the supported distros."
    echo 
    echo "Usage: $0 [--help] [--keep] [--verbose]"
    echo "    --help: show this help."
    echo "    --keep: don't destroy the EC2 instances after the test."
    echo "    --verbose: show full Terraform output."
    exit 0
fi

VERBOSE="false"
if [ "$1" == "--verbose" ]; then
    VERBOSE="true"
    shift
fi

cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"/terraform

echo "Initialising Terraform..."
if [ "$VERBOSE" == "true" ]; then
    terraform init
else
    terraform init > /dev/null
fi

echo "Creating EC2 instances & running test..."
if [ "$VERBOSE" == "true" ]; then
    terraform apply -auto-approve | tee output
else
    terraform apply -auto-approve > output
fi

if [ "$1" != "--keep" ]; then
    echo "Destroying instances..."
    if [ "$VERBOSE" == "true" ]; then
        terraform destroy -auto-approve
    else
        terraform destroy -auto-approve > /dev/null
    fi
fi

echo
echo "Test results"
echo "============"
for LINE in $(cat output | grep '==== Test result' | sort | cut -d' ' -f 6-); do echo -e $LINE | tr ':' '\t'; done
echo

if cat output | grep '==== Test result' | grep 'failure' 1>/dev/null; then
    echo -e "\033[1;31mOne or more tests failed\033[0m (./terraform/output contains the full log)"
    exit 1
else
    echo -e "\033[1;32mAll tests succeeded\033[0m"
    exit 0
fi
