#!/bin/bash

set -e

DIST=${DIST:-precise}
IMAGE=/tmp/$DIST-chroot
LOG=/tmp/travis.log

notice () {
  echo " --> $1"
}

mount_all () {
  notice "mount filesystems"
  sudo mount -t proc proc $1/proc/
  sudo mount -t sysfs sys $1/sys/
  sudo mount -o bind /dev $1/dev/
  sudo mount -t devpts devpts $1/dev/pts
}

copy_image () {
  notice "build image $1"
  sudo cp -r $IMAGE $1
}

gen_ssh_key () {
  notice "generate ssh keys"
  ssh-keygen -t rsa -N "" -f /tmp/id_rsa
  touch ~/.ssh/known_hosts
}

install_ssh_keys () {
  notice "install ssh key to $1"
  key=/tmp/id_rsa
  rm -f $key

  ssh-keygen -t rsa -f $key -N "" > /dev/null
  sudo chroot $1 /bin/sh -c "mkdir -p /root/.ssh && chmod 0700 /root/.ssh"
  sudo cp ${key}.pub $1/root/.ssh/authorized_keys
  sudo chroot $1 /bin/sh -c "chmod 0644 /root/.ssh/authorized_keys"
  sudo chroot $1 /bin/sh -c "chown root:root -R /root/.ssh"
  sudo chmod 0666 $key
  cp $key ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
}

setup_root_passwd () {
  notice "change root password in $1"
  sudo chroot $1 /bin/sh -c 'echo "root:root" | chpasswd'
}

spawn_sshd () {
  notice "spawn openssh server on localhost:$2"
  sudo chroot $1 /bin/sh -c "mkdir -p /var/run/sshd"
  sudo chroot $1 /usr/sbin/sshd -p $2
}

install_packages () {
  notice "add ansible ppa"
  echo "yes" | sudo add-apt-repository ppa:rquillo/ansible >> $LOG

  notice "apt-get update"
  sudo apt-get -qqy update >> $LOG

  notice "install packages"
  sudo apt-get -qqy install ansible debootstrap >> $LOG
}

run_debootstrap () {
  notice "run debootstrap in $IMAGE"
  sudo debootstrap --include="openssh-server,python" $DIST $IMAGE >> $LOG
  sudo mkdir -p $IMAGE/tmp
}

setup_apt_sources () {
  notice "setup apt sources"
  cat <<EOF > /tmp/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ $DIST main restricted universe multiverse
EOF
  sudo cp /tmp/sources.list $IMAGE/etc/apt/sources.list
  sudo chroot $IMAGE /usr/bin/apt-get -qqy update >> $LOG
}

test_connection () {
  notice "test connection"
  ANSIBLE_HOST_KEY_CHECKING=False ansible --private-key=~/.ssh/id_rsa -u root -i inventory/testing all -m setup >> $LOG
}

setup_container () {
  copy_image $1
  mount_all $1
  spawn_sshd $1 $2
}

echo > $LOG

install_packages
run_debootstrap
setup_apt_sources

setup_root_passwd $IMAGE
install_ssh_keys $IMAGE

setup_container /tmp/chroot-mq 2201
setup_container /tmp/chroot-web 2202
setup_container /tmp/chroot-worker 2203

test_connection
