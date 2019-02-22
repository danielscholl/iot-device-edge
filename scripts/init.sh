#!/usr/bin/env bash
#
#  Purpose: Initialize the Edge as Transparent Gateway
#  Usage:
#    init.sh

# Move the Certificates
printf "\n"
tput -T xterm setaf 2; echo "Moving the Certificates into place" ; tput -T xterm sgr0
tput -T xterm setaf 3; echo "------------------------------------" ; tput -T xterm sgr0
sudo mv certs /etc/iotedge/

# Rewrite the Configuration
printf "\n"
tput -T xterm setaf 2; echo "Moving the Configuration into place" ; tput -T xterm sgr0
tput -T xterm setaf 3; echo "------------------------------------" ; tput -T xterm sgr0
sudo cp /etc/iotedge/config.yaml /etc/iotedge/config_bu.yaml
sudo mv config.yaml /etc/iotedge/

# Rewrite the Configuration
printf "\n"
tput -T xterm setaf 2; echo "Starting up IotEdge" ; tput -T xterm sgr0
tput -T xterm setaf 3; echo "------------------------------------" ; tput -T xterm sgr0
sudo systemctl stop iotedge
sudo systemctl daemon-reload
sudo systemctl start iotedge
sudo systemctl status iotedge
