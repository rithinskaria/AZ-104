#!/bin/bash
sudo apt update -y
sudo apt install sshpass -y
colors=(red green blue)
for i in {0..2}
do
j=$(($i + 4))
ip="10.0.2.$j"
sshpass -p "VMP@55w0rd" ssh -o StrictHostKeyChecking=no rithin@$ip bash -c \
"'sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo echo "<html><body style=\"background-color:${colors[$i]};\"><h1 style=\"color:white;\">Hello world!</h1></body></html>" > /var/www/html/index.html
exit
'"
done
