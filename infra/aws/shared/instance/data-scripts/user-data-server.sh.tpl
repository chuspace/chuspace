#!/bin/bash

set -e

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-compose locales curl tzdata jq zip
sudo locale-gen en_GB.UTF-8

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip
rm -rf ./aws

sudo service docker restart
sudo usermod -aG docker ubuntu
sudo loginctl enable-linger ubuntu

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

mkdir prometheus

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

(
cat <<-EOF
#!/bin/bash

cd /home/ubuntu/app
cat /home/ubuntu/app/docker.txt | docker login -u chuspace2 --password-stdin
docker-compose stop
docker-compose rm -f
docker-compose pull
docker-compose up -d
EOF
) | sudo tee /home/ubuntu/app/start.sh

sudo chmod +x /home/ubuntu/app/start.sh

(
cat <<-EOF
[Unit]
Before=network.target
[Service]
Type=oneshot
ExecStart=/home/ubuntu/app/start.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/chuspace-app.service

sudo systemctl enable chuspace-app.service
sudo systemctl start chuspace-app.service
