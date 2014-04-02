#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install openjdk-7-jdk
sudo apt-get -y install maven
sudo apt-get -y install collectd
sudo cp /vagrant/provisioning/collectd.conf /etc/collectd/collectd.conf
sudo service collectd restart
sudo apt-get install -y git
git clone https://github.com/gdbtek/setup-graphite.git
cd setup-graphite/
sudo ./ubuntu.bash --login 'root' --password 'root' --email 'root@localhost.com'
cd bin/
sudo ./start