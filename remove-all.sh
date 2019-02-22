#!/usr/bin/env bash
#
#  Purpose: Removes all resources
#  Usage:
#    remove-all.sh

if [ -z $GROUP ]; then
  GROUP="iot-edge"
fi

if [ -z $DEVICE ]; then
  DEVICE="edge-vm"
fi

# Remove the Resource Group
printf "\n"
tput setaf 2; echo "Removing Azure Resource Group" ; tput sgr0
tput setaf 3; echo "-----------------------------" ; tput sgr0
az group delete \
  --name $GROUP \
  --yes \
  --no-wait

# Remove the Cert Folder Data
printf "\n"
tput setaf 2; echo "Removing Localhost Certificate Store" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
rm -f ./cert/config.yaml
rm -f ./cert/*.pem

# Remove the IoT Hub Device Identity
printf "\n"
tput setaf 2; echo "Removing IoT Hub Device Identity" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
az iot hub device-identity delete \
  --device-id $DEVICE \
  --hub-name $HUB \
  -oyaml
