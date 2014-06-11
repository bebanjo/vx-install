#!/bin/bash

set -e
set -x

export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive
export PYTHONUNBUFFERED=1

cd /tmp/provision

sudo apt-get install -qy python-software-properties
sudo apt-add-repository -y ppa:rquillo/ansible
sudo apt-get update
sudo apt-get install -qy ansible

mkdir ec2
cp production ec2/00_production
echo "[vexor-worker-ec2]" > ec2/10_ec2
echo "localhost credentials_dir=/tmp/provision/credentials/production" >> ec2/10_ec2

sudo env AWS_ACCESS_KEY=$AWS_ACCESS_KEY AWS_SECRET_KEY=$AWS_SECRET_KEY ansible-playbook playbooks/ec2.yml -i ec2/ -c local -v --sudo

sudo apt-get purge -qy ansible
sudo apt-get autoremove -qy

sync
sync
sync

