#!/bin/bash

set -e

mq_ip=$(vagrant ssh-config mq | grep HostName | awk '{ print $2 }')
web_ip=$(vagrant ssh-config web | grep HostName | awk '{ print $2 }')
worker_ip=$(vagrant ssh-config worker | grep HostName | awk '{ print $2 }')

cat << EOF
[vexor-mq]
$mq_ip

[vexor-web]
$web_ip

[vexor-worker]
$worker_ip

[vexor:children]
vexor-mq
vexor-worker
vexor-web

[vexor:vars]

vx_worker_pull_image=False
ansible_ssh_user=ubuntu
EOF
