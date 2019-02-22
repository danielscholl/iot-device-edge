#!/usr/bin/env bash
#
#  Purpose: Initialize the Edge as Transparent Gateway
#  Usage:
#    init.sh

# Move the Certificates
printf "\n"
tput setaf 2; echo "Moving the Certificates into place" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
sudo mv certs /etc/iotedge/

# Rewrite the Configuration
printf "\n"
tput setaf 2; echo "Moving the Configuration into place" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
sudo cp /etc/iotedge/config.yaml /etc/iotedge/config_bu.yaml
sudo mv config.yaml /etc/iotedge/

# Rewrite the Configuration
printf "\n"
tput setaf 2; echo "Starting up IotEdge" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
sudo systemctl stop iotedge
sudo systemctl daemon-reload
sudo systemctl start iotedge
sudo systemctl status iotedge
