#!/bin/bash

set -e

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-compose locales curl tzdata jq zip
sudo locale-gen en_GB.UTF-8

sudo adduser --disabled-password ubuntu < /dev/null
sudo mkdir -p /home/ubuntu/.ssh
sudo cp /root/.ssh/authorized_keys /home/ubuntu/.ssh
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip
rm -rf ./aws

sudo service docker restart
sudo usermod -aG docker $USER
sudo loginctl enable-linger $USER
docker swarm join --token $docker_swarm_token $docker_swarm_address:2377

# Fetch AWS secrets
mkdir -p /home/ubuntu/.aws

(
cat <<-EOF
[default]
region=${aws_region}
output=json
EOF
) | sudo tee /home/ubuntu/.aws/config

# Fetch credentials and docker image
mkdir /home/ubuntu/app
sudo chown ubuntu:ubuntu /home/ubuntu/app
cd /home/ubuntu/app

# Setup prometheus
mkdir /home/ubuntu/app/prometheus

(
cat <<-EOF
scrape_configs:
  - job_name: 'chuspace-app-metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:8080']

remote_write:
  - url: https://cloud.weave.works/api/prom/push
    basic_auth:
      password: ${weave_cloud_token}
EOF
) | sudo tee /home/ubuntu/app/prometheus/prometheus.yml

export AWS_ACCESS_KEY_ID=${aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
export AWS_DEFAULT_REGION=${aws_region}

echo ${docker_access_token} | sudo tee /home/ubuntu/app/docker.txt

(aws secretsmanager get-secret-value --secret-id chuspace-app/prod-env/${aws_ssm_secret_key_name} | jq '.SecretString' | xargs printf) > .env
cat /home/ubuntu/app/docker.txt | docker login -u chuspace2 --password-stdin

(
cat <<-EOF
${docker_compose}
EOF
) | tee /home/ubuntu/app/docker-compose.yml

sudo chown ubuntu:ubuntu /home/ubuntu/app/docker-compose.yml
cat /home/ubuntu/app/docker.txt | docker login -u chuspace2 --password-stdin

# Start docker services
docker-compose stop
docker-compose rm -f
docker-compose pull
docker-compose up -d

# Start weave scope for monitoring
cd /home/ubuntu

sudo curl -L git.io/scope -o /usr/local/bin/scope
sudo chmod a+x /usr/local/bin/scope
sudo scope launch --service-token=${weave_cloud_token}

# Cleanup credentials and files
rm -rf /home/ubuntu/app
rm -rf ~/.aws

