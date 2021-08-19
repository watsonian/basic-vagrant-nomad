#!/bin/bash

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common unzip vim jq -y

# echo "Installing Docker..."
# sudo apt-get update
# sudo apt-get remove docker docker-engine docker.io
# echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
# sudo apt-get install apt-transport-https ca-certificates curl software-properties-common unzip vim jq -y
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
# sudo apt-key fingerprint 0EBFCD88
# sudo add-apt-repository \
#       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#       $(lsb_release -cs) \
#       stable"
# sudo apt-get update
# sudo apt-get install -y docker-ce
# # Restart docker to make sure we get the latest version of the daemon if there is an upgrade
# sudo service docker restart
# # Make sure we can actually use docker as the vagrant user
# sudo usermod -aG docker vagrant
# sudo docker --version


# # Install required CNI plugins
# curl -sL -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
# sudo mkdir -p /opt/cni/bin
# sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

# # Ensure container traffic through bridge networks is allowed
# echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
# echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
# echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

# (
# cat <<-EOF
# net.bridge.bridge-nf-call-arptables = 1
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF
# ) | sudo tee /etc/sysctl.d/99-cni-bridge-settings.conf



echo "Installing Nomad..."
NOMAD_VERSION=1.1.3
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
sudo install nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
(
cat <<-EOF
  [Unit]
  Description=Nomad
  Documentation=https://www.nomadproject.io/docs/
  Wants=network-online.target
  After=network-online.target
  
  # When using Nomad with Consul it is not necessary to start Consul first. These
  # lines start Consul before Nomad as an optimization to avoid Nomad logging
  # that Consul is unavailable at startup.
  #Wants=consul.service
  #After=consul.service
  
  [Service]
  ExecReload=/bin/kill -HUP $MAINPID
  ExecStart=/usr/bin/nomad agent -config /vagrant/config/nomad-server.hcl
  KillMode=process
  KillSignal=SIGINT
  LimitNOFILE=65536
  LimitNPROC=infinity
  Restart=on-failure
  RestartSec=2
  
  ## Configure unit start rate limiting. Units which are started more than
  ## *burst* times within an *interval* time span are not permitted to start any
  ## more. Use StartLimitIntervalSec or StartLimitInterval (depending on
  ## systemd version) to configure the checking interval and StartLimitBurst
  ## to configure how many starts per interval are allowed. The values in the
  ## commented lines are defaults.
  
  # StartLimitBurst = 5
  
  ## StartLimitIntervalSec is used for systemd versions >= 230
  # StartLimitIntervalSec = 10s
  
  ## StartLimitInterval is used for systemd versions < 230
  # StartLimitInterval = 10s
  
  TasksMax=infinity
  OOMScoreAdjust=-1000
  
  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service

echo "Installing Consul..."
CONSUL_VERSION=1.9.8
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
  ExecStart=/bin/sh -c '/usr/bin/consul agent -dev -retry-join $(cat /vagrant/env/consul-server-1_ip) -config-file /vagrant/config/consul-client.hcl'
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
sudo systemctl enable consul.service
sudo systemctl start consul

for bin in cfssl cfssl-certinfo cfssljson
do
  echo "Installing $bin..."
  curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
  sudo install /tmp/${bin} /usr/local/bin/${bin}
done
nomad -autocomplete-install

sudo systemctl enable nomad.service
sudo systemctl start nomad