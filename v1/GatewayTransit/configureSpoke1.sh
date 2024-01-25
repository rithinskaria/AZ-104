#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo chown -R -v 777 /var/www/
echo "<html><body style=\"background-color:red;\"><h1 style=\"color:white;\">Hi from Spoke-1</h1></body></html>" > /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
echo "Configuration done"
