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

sudo service docker restart
sudo usermod -aG docker ubuntu
sudo loginctl enable-linger ubuntu

# Fetch credentials and docker image
mkdir /home/ubuntu/app
sudo chown ubuntu:ubuntu /home/ubuntu/app
cd /home/ubuntu/app

echo ${docker_access_token} | sudo tee /home/ubuntu/app/docker.txt

(
cat <<-EOF
${docker_compose}
EOF
) | tee /home/ubuntu/app/docker-compose.yml

sudo chown ubuntu:ubuntu /home/ubuntu/app/docker-compose.yml

(
cat <<-EOF
${app_env}
EOF
) | tee /home/ubuntu/app/.env

sudo chown ubuntu:ubuntu /home/ubuntu/app/.env

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
