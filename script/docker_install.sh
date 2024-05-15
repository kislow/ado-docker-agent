#!/bin/bash

############################################
# Dislaimer: Script tested in Ubuntu only  #
############################################

# remove any exisiting package

function cleanup_docker {
	echo "Clean up exisiting resources"
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc;
		do sudo apt-get remove $pkg; 
	done
}


function setup_docker_apt_repo {
	# Add Docker's official GPG key:
	echo "Setting up docker apt repo"
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
}


function install_latest_docker_version {
	echo "Installing latest docker version"
	sudo apt-get install \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin
}


function set_user_permission {
	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker
}


function sanity_check {

	echo "Check docker status..."
	sudo systemctl status docker

	echo " "
	echo "Check docker status..."
	docker ps
}


echo "Start docker instal..."

cleanup_docker

sleep 1
setup_docker_apt_repo

sleep 1
install_latest_docker_version

set_user_permission

echo "Sanity check..."
sanity_check
