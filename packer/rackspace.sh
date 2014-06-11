#!/bin/bash

set -e
set -x

export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive
export PYTHONUNBUFFERED=1

cd /tmp/provision

sudo apt-get update

sudo apt-get install -qy python-software-properties
sudo apt-add-repository -y ppa:rquillo/ansible
sudo apt-get update
sudo apt-get install -qy ansible

mkdir ec2
cp production ec2/00_production
echo "[vexor-worker-rackspace]" > ec2/10_ec2
echo "localhost credentials_dir=/tmp/provision/credentials/production" >> ec2/10_ec2

sudo env SDK_USERNAME=$SDK_USERNAME SDK_TOKEN=$SDK_API_KEY SDK_REGION=$SDK_REGION ansible-playbook playbooks/rackspace.yml -i ec2/ -c local -v --sudo

sudo apt-get purge -qy ansible
sudo apt-get autoremove -qy

sync
sync
sync

