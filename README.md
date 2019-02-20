# iot-edge

The purpose of this solution is to be able to easily deploy and run IoT Edge as either a VM or a Docker Container

__PreRequisites__

Requires the use of [direnv](https://direnv.net/).


## Provision the Azure Resources


The script requires an .envrc file to set environment variables used in creating the x509 certs.

```bash
# Azure Authentication for Docker
export ARM_SUBSCRIPTION_ID="<subscription>"
export ARM_TENANT_ID="<tenant>"
export ARM_CLIENT_ID="<client_id>"
export ARM_CLIENT_SECRET="<client_secret>"

# Project Settings
export AZURE_GROUP="iot-edge"
export HUB="<iot_hub>"
export DEVICE="edge-device"
export REGISTRY_SERVER="<docker_registry>"
```

```bash
AZURE_GROUP=iot-edge ./provision.sh

# SSH to the Edge Server and modify the configuration and restart
ssh <ipaddress>

$edge-vm: cp -r certs /etc/iotedge/
$edge-vm: cp config.yaml /etc/iotedge/
$edge-vm: sudo systemctl stop iotedge
$edge-vm: sudo systemctl daemon-reload
$edge-vm: sudo systemctl start iotedge

```


```bash
# Start IoT Edge as a Docker Container
docker-compose -p edge up -d

# Stop the IoT Edge Docker Container
docker-compose -p edge stop && docker-compose -p edge rm --force
```
