#!/bin/bash
sudo apt update -y
sudo apt install sshpass -y
for i in {0..1}
do
j=$(($i + 4))
k=$(($i + 1))
greenIp="10.0.1.$j"
sshpass -p "VMP@55w0rd" \
ssh -o StrictHostKeyChecking=no kodekloud@$greenIp bash -c  \
"'export VAR=$i
printenv | grep VAR
echo "Setting up green VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo curl "https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/AppGateway/sample.html" > /var/www/html/index.html
sed -i "s/PAGECOLOR/green/g" /var/www/html/index.html
sed -i "s/VMID/$k/g" /var/www/html/index.html
exit
'"
done

for i in {0..1}
do
j=$(($i + 4))
k=$(($i + 1))
redIp="10.0.2.$j"
sshpass -p "VMP@55w0rd" \
ssh -o StrictHostKeyChecking=no kodekloud@$redIp bash -c  \
"'export VAR=$i
printenv | grep VAR
echo "Setting up red VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo mkdir -v /var/www/html/red/
sudo curl "https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/AppGateway/sample.html" > /var/www/html/index.html
sed -i "s/PAGECOLOR/red/g" /var/www/html/index.html
sed -i "s/VMID/$k/g" /var/www/html/index.html
cat /var/www/html/index.html > /var/www/html/red/red.html
exit
'"

done

for i in {0..1}
do
j=$(($i + 4))
k=$(($i + 1))
blueIp="10.0.3.$j"
sshpass -p "VMP@55w0rd" \
ssh -o StrictHostKeyChecking=no kodekloud@$blueIp bash -c  \
"'export VAR=$i
printenv | grep VAR
echo "Setting up blue VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo mkdir -v /var/www/html/blue/
sudo curl "https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/AppGateway/sample.html" > /var/www/html/index.html
sed -i "s/PAGECOLOR/blue/g" /var/www/html/index.html
sed -i "s/VMID/$k/g" /var/www/html/index.html
cat /var/www/html/index.html > /var/www/html/blue/blue.html
exit
'"
done
