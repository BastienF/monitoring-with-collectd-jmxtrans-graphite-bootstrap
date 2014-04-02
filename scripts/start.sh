#!/bin/bash 

vagrant up
ssh -p 2200 -i ~/.vagrant.d/insecure_private_key vagrant@127.0.0.1 'cd /vagrant/; mvn clean package tomcat7:run'