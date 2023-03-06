#!/bin/bash
sudo yum update -y
sudo yum install -y amazon-efs-utils
sudo yum install -y nfs-utils
sudo yum install -y docker
sudo usermod -a -G docker ec2-user
newgrp docker
sudo systemctl start docker.service
sudo yum install -y mysql
mysql -h ${address} -u ${db_username} -p${db_password} -e "create database IF NOT EXISTS ${db_name}"
mkdir efs
sudo mount -t efs -o tls,accesspoint=${wp_efs_access_id} ${wp_efs_id} efs
sudo chmod 777 /efs
docker run -p 80:80   --env WORDPRESS_DB_HOST=${address} --env WORDPRESS_DB_PASSWORD=${db_password}  --env WORDPRESS_DB_USER=${db_username}   --volume /efs:/var/www/html --user 33:33  wordpress:${wp_version}