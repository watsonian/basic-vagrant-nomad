#!/bin/bash

# Packages required for consul
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common unzip vim jq -y

echo "Installing Consul..."
CONSUL_VERSION=1.9.8
cd /tmp/
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
(
cat <<-EOF
  [Unit]
  Description=consul agent
  Requires=network-online.target
  After=network-online.target

  [Service]
  Restart=on-failure
  ExecStart=/bin/sh -c '/usr/bin/consul agent -dev -advertise $(cat /vagrant/env/${HOSTNAME}_ip) -config-file /vagrant/config/consul-server.hcl'
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
sudo systemctl enable consul.service
sudo systemctl start consul

# for bin in cfssl cfssl-certinfo cfssljson
# do
#   echo "Installing $bin..."
#   curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
#   sudo install /tmp/${bin} /usr/local/bin/${bin}
# done
