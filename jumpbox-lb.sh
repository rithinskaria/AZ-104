#!/bin/bash
sudo apt update -y
sudo apt install sshpass -y
sshpass -p "VMP@55w0rd" ssh -o StrictHostKeyChecking=no
rithin@10.0.2.4 <<EOF
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo echo "Hello from web-01" > /var/www/html/index.html
exit
EOF
sshpass -p "VMP@55w0rd" ssh -o StrictHostKeyChecking=no rithin@10.0.2.5 <<EOF
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo echo "Hello from web-02" > /var/www/html/index.html
exit
EOF
sshpass -p "VMP@55w0rd" ssh -o StrictHostKeyChecking=no rithin@10.0.2.6 <<EOF
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo echo "Hello from web-03" > /var/www/html/index.html
exit
EOF
