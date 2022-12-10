#!/bin/sh
CUSER=tima7442

printf "Creating NEW SHH KEY\n"
ssh-keygen

printf "ADDING SHH into authentication agent\n"
eval 'ssh-agent'
sudo chmod 400 .ssh/id_rsa.pub
ssh-add
ssh-add -l

echo -e "Copy this key to your OpenNebula profile. You have 1 minutes for it. \n"
cat ~/.ssh/id_rsa.pub

sleep 60

printf "Installing updated\n"

sudo apt update

printf "Installing Git\n"
sudo apt install git

printf "Installing OpenNebula"

git clone https://github.com/OpenNebula/one.git
sudo apt install gnupg2
wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | sudo tee /etc/apt/sources.list.d/opennebula.list
sudo apt update

sudo apt install opennebula

printf "Installing ansible\n"
sudo apt install ansible -y
ansible --version



printf "Creating VMs \n"
CENDPOINT=https://grid5.mif.vu.lt/cloud3/RPC2
CUSER_WEB=dato8727
CPASS_WEB="Ilovefrogs2015#"
CUSER_DB=dima7574
CPASS_DB="L1NUX+itmoksl123"
CUSER_CLIENT=tima7442
CPASS_CLIENT="zoqqB2++"

CVMREZ=$(onetemplate instantiate "debian11" --name "WEBSERVER_VM"  --raw TCP_PORT_FORWARDING=80 --user $CUSER_WEB --password $CPASS_WEB --endpoint $CENDPOINT)
WEBSERVERID=$(echo $CVMREZ | cut -d ' ' -f 3)
echo -e "\n\nWEBSERVER ID: ${WEBSERVERID}"

CVMREZ=$(onetemplate instantiate "debian11" --name "DB_VM" --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT)
DBID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "\n\nDATABASE ID: ${DBID}"

CVMREZ=$(onetemplate instantiate "debian11" --name "CLIENT_VM" --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT)
CLIENTID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "\n\nCLIENT ID: ${CLIENTID}"

sleep 30

mkdir /etc/ansible

onevm show $DBID --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT > /etc/ansible/database.txt
onevm show $WEBSERVERID --user $CUSER_WEB --password $CPASS_WEB  --endpoint $CENDPOINT > /etc/ansible/webserver.txt

onevm show $CLIENTID --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT > /etc/ansible/client.txt

IPWEB=$(cat /etc/ansible/webserver.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPDB=$(cat /etc/ansible/database.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPCLIENT=$(cat /etc/ansible/client.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')

ssh-keygen -R $IPWEB
ssh-keygen -R $IPDB
ssh-keygen -R $IPCLIENT

ssh-keyscan $IPWEB >> ~/.ssh/known_hosts
ssh-keyscan $IPDB >> ~/.ssh/known_hosts
ssh-keyscan $IPCLIENT >> ~/.ssh/known_hosts

echo -e "[webserver]\n$IPWEB\n\n[database]\n$IPDB\n\n[client]" > /etc/ansible/hosts

echo "PINGING ALL MACHINES"
ansible all -m ping
echo "PINGED"

echo '<?php $ip="' > vars.php
echo $IPDB >> vars.php
echo '"; ?>' >> vars.php

git clone https://github.com/Jamtit/Virt-Service.git

echo -e "\n Playing playbook for Database"
ansible-playbook ~/Virt-Service/database.yaml

echo -e "\n Playing playbook for Webserver"
ansible-playbook ~/Virt-Service/web.yaml

onevm reboot ${CLIENTID} --user ${CUSER_CLIENT} --password ${CPASS_CLIENT} --endpoint ${CENDPOINT}
onevm reboot ${DBID} --user ${CUSER_DB} --password ${CPASS_DB} --endpoint ${CENDPOINT}
onevm reboot ${WEBSERVERID} --user ${CUSER_WEB} --password ${CPASS_WEB} --endpoint ${CENDPOINT}

echo "Rebooting VMs, please wait 30s"
sleep 30

printf "Done\n"