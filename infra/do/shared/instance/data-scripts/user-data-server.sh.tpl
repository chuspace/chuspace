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
./aws/install
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

curl -1sLf \
  'https://repositories.timber.io/public/vector/cfg/setup/bash.deb.sh' \
  | sudo -E bash

sudo apt-get install -y  vector=0.22.3-1
sudo wget -O /etc/vector/vector.toml https://logtail.com/vector-toml/docker/${logtail_token}
sudo usermod -a -G docker vector
sudo systemctl restart vector

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

# Add weave scope
sudo curl -L git.io/scope -o /usr/local/bin/scope
sudo chmod a+x /usr/local/bin/scope
scope launch 52.213.227.157
