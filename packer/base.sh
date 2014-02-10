#!/bin/bash

set -e

export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get -qy upgrade

#sudo apt-get install -qy python-software-properties
sudo apt-add-repository -y ppa:rquillo/ansible
sudo apt-get update
sudo apt-get install -qy ansible

sudo apt-get clean
sudo apt-get autoremove

mkdir /tmp/ansible

sudo reboot

sleep 10
