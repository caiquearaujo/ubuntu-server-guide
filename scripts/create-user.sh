#!/bin/bash
CURR_USER=$1

if [ -z "$CURR_USER" ]
then
	printf "Insira um nome de usuário após o comando. \n"
	exit
fi

printf  "Criando o usuário: %s \n" "$CURR_USER"

sudo adduser $CURR_USER
sudo mkdir -p /home/$CURR_USER/.ssh
sudo chmod 700 /home/$CURR_USER/.ssh
sudo touch /home/$CURR_USER/.ssh/authorized_keys
sudo chmod 600 /home/$CURR_USER/.ssh/authorized_keys
sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER
sudo chown root:root /home/$CURR_USER
sudo chmod 755 /home/$CURR_USER
sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER