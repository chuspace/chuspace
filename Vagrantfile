# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

IP = {
  nomad: {
    host: '192.168.50.7',
    port: [4646, 8500, 8600]
  },
  gitea: {
    host: '192.168.50.4',
    port: [3033]
  },
  drone: {
    host: '192.168.50.5',
    port: [3034]
  },
  runner: {
    host: '192.168.50.6',
    port: []
  },
  chuspace: {
    host: '192.168.50.9',
    port: [3036]
  },
  seaweedfs: {
    host: '192.168.50.8',
    port: [9333, 8333, 8888]
  }
}.freeze

docker_script = <<SCRIPT
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# Make sure we can actually use docker as the vagrant user
sudo service docker restart
sudo usermod -aG docker vagrant
sudo docker --version
SCRIPT

nomad_script = <<SCRIPT
#{docker_script}
sudo apt-get install unzip curl vim -y
echo "----------------"
echo "Installing Consul..."
cd /tmp/
CONSUL_VERSION=1.11.4
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d
(
cat <<-EOF
  node_name = "consul-server"
  bind_addr = "#{IP[:nomad][:host]}"
  client_addr = "0.0.0.0"
  server    = true
  bootstrap = true
  server = true
  bootstrap_expect = 1
  ui_config {
    enabled = true
  }
  datacenter = "dc1"
  data_dir   = "/var/lib/consul"
  log_level  = "INFO"
  connect {
    enabled = true
  }
EOF
) | sudo tee /etc/consul.d/consul.hcl
(
cat <<-EOF
  [Unit]
  Description=consul agent
  Requires=network-online.target
  After=network-online.target
  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
  ExecReload=/bin/kill -HUP $MAINPID
  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
for bin in cfssl cfssl-certinfo cfssljson
do
echo "Installing $bin..."
curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
sudo install /tmp/${bin} /usr/local/bin/${bin}
done
sudo mkdir /etc/systemd/resolved.conf.d
(
cat <<-EOF
  [Resolve]
  DNS=127.0.0.1
  DNSSEC=false
  Domains=~consul
EOF
) | sudo tee /etc/systemd/resolved.conf.d/consul.conf
sudo iptables --table nat --append OUTPUT --destination localhost --protocol udp --match udp --dport 53 --jump REDIRECT --to-ports 8600
sudo iptables --table nat --append OUTPUT --destination localhost --protocol tcp --match tcp --dport 53 --jump REDIRECT --to-ports 8600
sudo systemctl restart systemd-resolved
systemctl is-active systemd-resolved
resolvectl domain
sudo systemctl enable consul.service
sudo systemctl start consul
echo "----------------"
echo "Check domain discovery"
sleep 5
resolvectl query consul.service.consul
host consul.service.consul
echo "----------------"
echo "Installing Nomad..."
NOMAD_VERSION=1.2.6
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
sudo install nomad /usr/bin/nomad
mkdir -p /opt/drone/data
sudo chmod a+w /opt/drone/data
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables
(
cat <<-EOF
  data_dir  = "/var/lib/nomad"
  bind_addr = "#{IP[:nomad][:host]}"
  server {
    enabled = true
    bootstrap_expect = 1
  }
  advertise {
    http = "#{IP[:nomad][:host]}"
  }
  client {
    enabled = true
    network_interface = "enp0s8"
    servers = ["#{IP[:nomad][:host]}:4646"]
    host_volume "drone" {
      path      = "/opt/drone/data"
      read_only = false
    }
  }
  plugin "raw_exec" {
    config {
      enabled = true
    }
  }
  consul {
    address = "#{IP[:nomad][:host]}:8500"
  }
EOF
) | sudo tee /etc/nomad.d/nomad.hcl
(
cat <<-EOF
  [Unit]
  Description=nomad agent
  Requires=network-online.target
  After=network-online.target
  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/nomad agent -log-level INFO -config=/etc/nomad.d
  ExecReload=/bin/kill -HUP $MAINPID
  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service
  sudo systemctl enable nomad.service
  sudo systemctl start nomad
  echo "export NOMAD_ADDR=http://#{IP[:nomad][:host]}:4646" >> ~/.bashrc
  export NOMAD_ADDR=http://#{IP[:nomad][:host]}:4646
SCRIPT

gitea_script = <<SCRIPT
wget -O gitea https://dl.gitea.io/gitea/1.16.5/gitea-1.16.5-linux-amd64
chmod +x gitea
gpg --keyserver keys.openpgp.org --recv 7C9E68152594688862D62AF62D9AE806EC1592E2
gpg --verify gitea-1.16.5-linux-amd64.asc gitea-1.16.5-linux-amd64
adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --group \
   --disabled-password \
   --home /home/git \
   git
mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea
export GITEA_WORK_DIR=/var/lib/gitea/
cp gitea /usr/local/bin/gitea
(
cat <<-EOF
[Unit]
  Description=Gitea
  After=syslog.target
  After=network.target
  [Service]
  RestartSec=2s
  Type=simple
  User=git
  Group=git
  WorkingDirectory=/var/lib/gitea/
  ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini -p #{IP[:gitea][:port].first}
  Restart=always
  Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/gitea.service
sudo systemctl enable gitea.service
sudo systemctl start gitea
SCRIPT

drone_script = <<SCRIPT
#{docker_script}
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo tee -a docker-compose.yml << END
version: '3'
services:
  drone-server:
    image: drone/drone:2
    container_name: drone-server
    ports:
      - 3034:80
      - 9000
    volumes:
      - drone-server-data:/var/lib/drone/
    restart: always
    environment:
      - DRONE_GITEA_SERVER=http://#{IP[:gitea][:host]}:#{IP[:gitea][:port].first}
      - DRONE_GITEA_CLIENT_ID=c98389dd-7a40-4056-b280-67dc24b2e7a5
      - DRONE_GITEA_CLIENT_SECRET=mh7c8TjOmHQOgJs2eubMXQnRt2rZQx7JlyN0E0G2Uj16
      - DRONE_RPC_SECRET=6b58b2a151db1fddfd56f8e5e99adecd
      - DRONE_SERVER_HOST=#{IP[:drone][:host]}:#{IP[:drone][:port].first}
      - DRONE_SERVER_PROTO=http
      - DRONE_GIT_ALWAYS_AUTH=false
      - DRONE_LOGS_DEBUG=true
      - DRONE_LOGS_TEXT=true
      - DRONE_LOGS_PRETTY=true
      - DRONE_LOGS_COLOR=true
      - DRONE_USER_CREATE="username:gaurav,machine:false,admin:true,token:6b58b2a151db1fddfd56f8e5e99adecd"
      - DRONE_DATABASE_DRIVER=sqlite3
      - DRONE_DATABASE_DATASOURCE=/tmp/drone.sqlite
volumes:
  drone-server-data:
END
docker-compose up -d
SCRIPT

drone_runner_script = <<SCRIPT
#{docker_script}
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo tee -a docker-compose.yml << END
version: '3'
services:
  drone-agent:
    image: drone/drone-runner-docker:1
    container_name: drone-runner
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_RPC_PROTO=http
      - DRONE_RPC_HOST=#{IP[:drone][:host]}:#{IP[:drone][:port].first}
      - DRONE_RPC_SECRET=6b58b2a151db1fddfd56f8e5e99adecd
      - DRONE_RUNNER_CAPACITY=3
      - DRONE_RUNNER_NAME=chuspace
END
docker-compose up -d
SCRIPT

seaweedfs_script = <<SCRIPT
echo "_____________"
echo "Installing seaweedfs"
wget -q https://github.com/chrislusf/seaweedfs/releases/download/2.96/linux_amd64_large_disk.tar.gz
tar -xzvf linux_amd64_large_disk.tar.gz
mv weed /usr/local/bin
mkdir -p /mnt/storage
(
cat <<-EOF
[Unit]
Description=Seaweed server
After=network.target
[Service]
Type=simple
Restart=on-failure
#User=seaweed
#Group=seaweed
ExecStart=/usr/local/bin/weed server -s3 -s3.domainName=chuspace.dev -dir=/mnt/storage -ip=#{IP[:seaweedfs][:host]} -volume.max=0 -master.volumeSizeLimitMB=2048 -master.volumePreallocate=false
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/seaweedfs.service
sudo systemctl enable seaweedfs.service
sudo systemctl start seaweedfs
SCRIPT

chuspace_script = <<SCRIPT
echo "_____________"
echo "Installing dependencies"

apt-get -y update
apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-dev \
                   git-core curl locales libsqlite3-dev tzdata redis-server libpq-dev postgresql postgresql-contrib

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChC1ZccKa+LyOCTsROiaFNoBfvP5z7NQKUwU7Tn1RumEBCRp+IFL/CFa9SZbjpqY//jd6VbNy/KzJJQjRybNhHeAeMCATuyM+VkrkkGegJJK+lhwI2p1rqX42t/7Zz/ViQ3S1GY4Myn1uhhu5uS+kJazSiGGLEoDZFC+mBffCYIcB6pweOI9zc2tfSGvOHApjy1WbYEvPsWYoxqMqIfR4VcfrmfddcP9T2LL9YcTpJiaLhyAHIL7xHdHQ8XCh2aMGqEbfHH2FosEus3Gxaio2B2HmKMo/gQraOEc0kjeU+LEVuq9B52hUBvqkXAN/u2hOFvxYtfMkD6t3CAdV9N8N9 gaurav@Gauravs-MacBook-Pro.localssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChC1ZccKa+LyOCTsROiaFNoBfvP5z7NQKUwU7Tn1RumEBCRp+IFL/CFa9SZbjpqY//jd6VbNy/KzJJQjRybNhHeAeMCATuyM+VkrkkGegJJK+lhwI2p1rqX42t/7Zz/ViQ3S1GY4Myn1uhhu5uS+kJazSiGGLEoDZFC+mBffCYIcB6pweOI9zc2tfSGvOHApjy1WbYEvPsWYoxqMqIfR4VcfrmfddcP9T2LL9YcTpJiaLhyAHIL7xHdHQ8XCh2aMGqEbfHH2FosEus3Gxaio2B2HmKMo/gQraOEc0kjeU+LEVuq9B52hUBvqkXAN/u2hOFvxYtfMkD6t3CAdV9N8N9 gaurav@Gauravs-MacBook-Pro.local" >> /home/vagrant/.ssh/authorized_keys
cat /home/vagrant/.ssh/authorized_keys
locale-gen en_US.UTF-8
adduser --disabled-password deployer < /dev/null
mkdir -p /home/deployer/.ssh
cp /home/vagrant/.ssh/authorized_keys /home/deployer/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsG8LGXfk16RelzxmqbAqHnAnwprR2eTXHIoIAZuTyipWHUGM0WCtGsRXVA/mf1TOu0MyOyi/s4M/DLO7JessUqvhMt8gVLjhG6JLN7nZbtmDWdsMQ5WOZIw75cjwur1/GFvGksHNzSDEjnxasISCQMS4Y0TyCVp7z75o/sN4G1YyMJdfASAzF0FLdM8sz0FKqNZurKFQ2+CBu1/Zz8w1MWko9LIPbVaDDqueRnrb5btcPs92xzzN40et62NWEVa0yWCiCiwBeVtywdatt9B5OR5/qxyIV4L33XnAkadr+hmFqBeiiyQr53LxeKCKhgiWKzFKZyRCCL0tv6GnVgaeQS7L14NMQ2/vQsSOJy/Dit4chuI7zed+dpIo6A/sFIWDbQmXBufs9pDDsGm4JJzl85FCS1GsoeTxdPFbY+xm2OSJer1oH9pDsibb0BM9jJv4DgCGnT3tBDD6iY4y+f7sHzyAQ8dOO5plC9bF7f6sn8jO8xXIw0c+TbYvWwtUKmY0= vagrant@chuspace" >> /home/deployer/.ssh/id_rsa.pub
echo "-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEA7BvCxl35NekXpc8ZqmwKh5wJ8Ka0dnk1xyKCAGbk8oqVh1BjNFgr
RrEV1QP5n9UzrtDMjsov7ODPwyzuyXrLFKr4TLfIFS44RuiSze52W7Zg1nbDEOVjmSMO+X
I8Lq9fxhbxpLBzc0gxI58WrCEgkDEuGNE8glae8++aP7DeBtWMjCXXwEgMxdBS3TPLM9BS
qjWbqyhUNvggbtf2c/MNTFpKPSyD21Wgw6rnkZ62+W7XD7Pdsc8zeNHretjVhFWtMlgogo
sAXlbcsHWrbfQeTkef6sciFeC9915wJGna/oZhagXooskK+dy8XigioYIlisxSmckQgi9L
b+hp1YGnkEuy9eDTENv70LEjicvw4reHIbiO83nfnaSKOgP7BSFg20Jlwbn7PaQw7BpuCS
c5fORQktRrKHk8XTxW2PsZtjkiXq9aB/aQ7Im29ATPYyb+A4Ahp097QQw+omOMvn+7B88g
EPHTjuaZQvWxe3+rJ/IzvMVyMNHPk22L1sLVCpmNAAAFiLUaf8u1Gn/LAAAAB3NzaC1yc2
EAAAGBAOwbwsZd+TXpF6XPGapsCoecCfCmtHZ5NcciggBm5PKKlYdQYzRYK0axFdUD+Z/V
M67QzI7KL+zgz8Ms7sl6yxSq+Ey3yBUuOEboks3udlu2YNZ2wxDlY5kjDvlyPC6vX8YW8a
Swc3NIMSOfFqwhIJAxLhjRPIJWnvPvmj+w3gbVjIwl18BIDMXQUt0zyzPQUqo1m6soVDb4
IG7X9nPzDUxaSj0sg9tVoMOq55Getvlu1w+z3bHPM3jR63rY1YRVrTJYKIKLAF5W3LB1q2
30Hk5Hn+rHIhXgvfdecCRp2v6GYWoF6KLJCvncvF4oIqGCJYrMUpnJEIIvS2/oadWBp5BL
svXg0xDb+9CxI4nL8OK3hyG4jvN5352kijoD+wUhYNtCZcG5+z2kMOwabgknOXzkUJLUay
h5PF08Vtj7GbY5Il6vWgf2kOyJtvQEz2Mm/gOAIadPe0EMPqJjjL5/uwfPIBDx047mmUL1
sXt/qyfyM7zFcjDRz5Nti9bC1QqZjQAAAAMBAAEAAAGAMIC3b3aolkmPARHdTOQq+Za1eA
lW8yuNP544JIr+p1COzSBXcM5X/YqtWHgblJkAp/3et8qTM88u/wJA/4TJKTLCFUh/wtIe
33oxhjpheA+sLwJwqgzle/T2w4mTEWgXfaMC+vkAjoMbDR1GVA/uF5DyzkhVbNUMjEIBZu
oXgkHmQHgZrTdf4FceXrCgIsG96ZdfpjZ/rlckmoCk8UbRyYiWzaBSagFaKDf4oDKBlhYN
+fzSIw/UnBJLlI3stuW+bJQBN2aQVZ4puULQC8rX5/Nd5Or9IxGWJWwGFd6wdIEDhheEGm
JwZEtNXcNQ+wMREIXYqNuksaHKBsWuFbbgqSzUuOB37faqvo0CXgLscUwt16e5BcptViI+
jkHpFSt3/gcDlzSligroB58OuVsgnIOkYqt5ibgU+2WMOjyaNZMSDkaJo7abvPz4SDomTS
PhaNBdd/a4IMkYcZwY8MumJSf7zj2JY3Gx0cL5Ks1T9ZWyrXPnEeIuLpF47S3llPPBAAAA
wDULYettu6J1ZhMBBCmnv2NmxX9DT1BUVqF4QFWMbR1O+/zR2x87kADKHGPT2kL2fVod8N
NNPkpvVHVIhRaNXujClpSON0s9/C5zTBzd3VH8FoHCTMTB7ileRTqLmNWljH/2OlNlbO1p
ZI3vPSl1ALNVYKADwt/vO5RE+DdrK056/3i3JluKk/DKHep9ZWMX66PFntMVsFQkc6Reeq
KDpe3cEknDGhYUbAFSbjLEWnWorogxtQzobiXmxsb3KF9cTwAAAMEA/eblCRSeSWRnQT4k
h5VDt4ovP+Bxrqe7Zn5Nu8NpBp0x1UDqj9J5+H/S7MkCNPeqK1N/UkL3mo+NCli2gg1kz3
AuaT1YhecurFD6yOAkGYnst2L6Ma9Xtoi38Z6UBrBRAdDqU+17JuR1QBVLC38F7sKkZpiv
KTO/DX0bC99CvhTf0gWBvPD68DHMdUnawl4p3o3Ya4jhbsJUYzU/Vzwo838GKkrle4NUCz
xFud7x/hA9ogIEdjdgRrpgrt7PvbVdAAAAwQDuDznJv47lm+8CQBPxNhJ/QE4JJF95VI8M
lZrLlwSNTa4WINnB1aL16/MjqbpJqpjQ6umNOjKWw0BapvpIY1lmOOccLga2t7YhNG0TCq
v7CvlcXdIb4EM/Z1YRF2VgSGK1KZMKnJZSykQdNxUtk+6TR6Do8Q7mMqHZcbJ/Vx7JMCbD
CQk2zdgW/TV8nIV6u1sGKlFxFyp/YPT6FrtyF2F2JJ1KeYduxc0vkh48dLBcfQFbzY3BHu
R+i4NCYc9bgfEAAAAQdmFncmFudEBjaHVzcGFjZQECAw==
-----END OPENSSH PRIVATE KEY-----" >> /home/deployer/.ssh/id_rsa
chown -R deployer:deployer /home/deployer/.ssh
chmod 600 /home/deployer/.ssh/authorized_keys
chmod 400 /home/deployer/.ssh/id_rsa
mkdir -p /var/www
chown deployer:deployer /var/www
loginctl enable-linger deployer
sudo systemctl start postgresql.service
sudo -u postgres createuser vagrant -s && sudo -u postgres createdb vagrant
echo "_____________"
echo "All done"
SCRIPT

SCRIPT = {
  gitea: gitea_script,
  drone: drone_script,
  nomad: nomad_script,
  runner: drone_runner_script,
  seaweedfs: seaweedfs_script,
  chuspace: chuspace_script
}.freeze

BOX_IMAGE = 'ubuntu/focal64'

Vagrant.configure('2') do |config|
  IP.each_with_index do |(name, host_config), index|
    config.vm.define name do |vm_config|
      vm_config.vm.box = BOX_IMAGE
      vm_config.vm.hostname = name
      vm_config.vm.provision 'shell', inline: SCRIPT[name]
      host_config[:port].each do |port|
        vm_config.vm.network 'forwarded_port', guest: port, host: port
      end
      vm_config.vm.network :private_network, ip: host_config[:host]
    end
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '2048'
  end
end