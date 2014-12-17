#!/usr/bin/env bash
 
printf "\nCopying default.vhost file to /etc/apache2/sites-available/default\n"
cp /vagrant/provisioning/default.vhost /etc/apache2/sites-available/000-default.conf
 
printf "\nReloading apache\n"
service apache2 reload