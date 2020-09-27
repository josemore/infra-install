![End-to-end test](https://github.com/fryckbos/infra-install/workflows/End-to-end%20test/badge.svg)

# Install New Relic Infra agent on Linux

This repository contains a script (`install.sh`) that provides an easy way to install the New Relic Infra agent on the following Linux distributions:

 - **Amazon Linux** (2, 1)
 - **Debian** (10, 9, 8)
 - **CentOS** (8, 7, 6)
 - **Red Hat Enterprise Linux** (8, 7, 6)
 - **SUSE Linux Enterprise Server** (15, 12, 11)
 - **Ubuntu** (20.04, 18.04, 16.04, 14.04, 12.04)

# Usage

Get your license key from the New Relic UI and execute the script with the license key in the `NR_LICENSE_KEY` environment variable:

```NR_LICENSE_KEY={{LICENSE KEY}} bash -c "$(curl -L https://raw.githubusercontent.com/fryckbos/infra-install/master/install.sh)"```

# Contributing

This repo is open to contributions, such as adding a new Linux distribution or version:

 - Make your changes
 - Update the tests to cover potential new distros
 - Run the tests to ensure they pass
 - Create a PR to this repo

# License

This project is licensed under the Apache 2 License.

# End-to-end tests

The end-to-end test (`test-all.sh`) uses **Terraform** to deploy an EC2 instance for each of the supported Linux distributions. The following steps are executed:
 - terraform init
 - terraform apply
 - terraform destroy
 - processing of the results

During the `terraform apply` phase, the `test/test.sh` script is copied to the EC2 instances and the following steps are executed:
 - setup required testing dependencies
 - setup hosts file and run netcat to capture data going to New Relic on localhost
 - curl-into-bash installation using the `install.sh` script
 - wait until we capture network data for New Relic (3 min timeout)

## Adding a new distribution

The Terraform variables file (`test/variables.tf`) contains the tested Linux distributions. There are 3 co-indexed lists: `distros`, `amis` and `ami_users`.

In order to add a distribution, add the name of the distribution to the `distros` list, the ami-id to the `amis` list and the username to ssh into the EC2 instance to the `ami_users` list. 

Make sure to add the name, ami-id and username to the same position in the list (for example the last position).

## Running the tests locally

Prerequisites
 - An AWS account
 - Setup the AWS configuration and credentials file as described [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
 - SSH keypair in `~/.ssh/id_rsa.pub` and `~/.ssh/id_rsa`

After running the `test-all.sh` script, the output of the terraform apply can be found in `test/output`. There you can find the output of all `test.sh` script runs prefixed with the instance.

To debug the tests, you can run `test-all.sh --keep` to keep the EC2 instances. You can login to the instances by looking up the IP address using `cd test && terraform show`. Make sure to use the username specified in the variables to login (eg. `ssh centos@1.2.3.4` for CentOS boxes).

Use `cd test && terraform destroy` to destroy the instances.
