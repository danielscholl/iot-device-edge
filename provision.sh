#!/usr/bin/env bash
#
#  Purpose: Create a Resource Group an Edge VM deployed to it
#  Usage:
#    provision-edge.sh


###############################
## ARGUMENT INPUT            ##
###############################

usage() { echo "Usage: provision.sh " 1>&2; exit 1; }

if [ -f ./.envrc ]; then source ./.envrc; fi

if [ -z $AZURE_LOCATION ]; then
  AZURE_LOCATION="eastus"
fi

if [ -z $GROUP ]; then
  GROUP="iot-edge"
fi

if [ -z $DEVICE ]; then
  DEVICE="edge-vm"
fi

if [ -z $IMAGE]; then
  IMAGE="Canonical:UbuntuServer:18.04-LTS:18.04.201809110"
fi

##############################
## Deploy EDGE Resources    ##
##############################
printf "\n"
tput setaf 2; echo "Deploying the Edge VM" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

az group create \
  --name $GROUP \
  --location $AZURE_LOCATION \
  -oyaml

az vm create \
  --name $DEVICE \
  --resource-group $GROUP \
  --image $IMAGE \
  --ssh-key-value ~/.ssh/id_rsa.pub \
  --custom-data bootstrap.sh \
  -oyaml

ipAddress=$(az vm list-ip-addresses \
  --resource-group $GROUP \
  --name $DEVICE \
  --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -otsv)


printf "\n"
tput setaf 2; echo "Creating IoT Edge Device" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
az iot hub device-identity create \
  --device-id $DEVICE \
  --hub-name $HUB \
  --edge-enabled \
  -oyaml

printf "\n"
tput setaf 2; echo "Updating the Device Twin" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
az iot hub device-twin update \
  --device-id $DEVICE \
  --hub-name $HUB \
  --set tags='{"environment":"'$ENVIRONMENT'"}' \
  -oyaml


printf "\n"
tput setaf 2; echo "Creating Configuration File" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
DEVICE_CONNECTION_STRING=$(az iot hub device-identity show-connection-string \
                            --device-id $DEVICE \
                            --hub-name $HUB \
                            -otsv)

cat <<EOF > private/config.yaml
provisioning:
  source: "manual"
  device_connection_string: "$DEVICE_CONNECTION_STRING"
certificates:
  device_ca_cert: "/etc/iotedge/certs/$DEVICE.cert.pem"
  device_ca_pk: "/etc/iotedge/certs/$DEVICE.key.pem"
  trusted_ca_certs: "/etc/iotedge/certs/root.ca.cert.pem"
agent:
  name: "edgeAgent"
  type: "docker"
  env: {}
  config:
    image: "mcr.microsoft.com/azureiotedge-agent:1.0"
    auth: {}
hostname: "$DEVICE.local"
connect:
  management_uri: "unix:///var/run/iotedge/mgmt.sock"
  workload_uri: "unix:///var/run/iotedge/workload.sock"
listen:
  management_uri: "fd://iotedge.mgmt.socket"
  workload_uri: "fd://iotedge.socket"
homedir: "/var/lib/iotedge"
moby_runtime:
  uri: "unix:///var/run/docker.sock"
EOF

printf "\n"
tput setaf 2; echo "Copying Files to Server" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
ssh -o StrictHostKeyChecking=no $ipAddress "mkdir -p ~/certs"
scp -o StrictHostKeyChecking=no private/*.pem $ipAddress:~/certs
scp -o StrictHostKeyChecking=no private/config.yaml $ipAddress:~/config.yaml


printf "\n"
tput setaf 2; echo "Connect to Edge VM" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
echo "Please wait a few minutes before attaching to allow the installations of the Azure CLI, Moby and the IoT Edge Runtime to complete."
printf "\n"
echo "Access Edge VM and run the following commands:  ssh $ipAddress"
echo
echo "sudo cp -r certs /etc/iotedge/"
echo "sudo cp config.yaml /etc/iotedge/"
echo "sudo systemctl stop iotedge"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl start iotedge"

