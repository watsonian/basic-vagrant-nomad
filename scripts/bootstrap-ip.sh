#!/bin/bash

mkdir -p /vagrant/env

interface="eth1"
ip=$(ifconfig ${interface} | grep "inet " | awk '{print $2}')

echo "Waiting for $interface IP address..."
while [ "$ip" = "" ]; do
  sleep 1
  ip=$(ifconfig ${interface} | grep "inet " | awk '{print $2}')
done

echo "IP address is $ip"

echo "$ip" > /vagrant/env/${HOSTNAME}_ip
