# iot-device-edge

The purpose of this solution is to be able to easily deploy and run IoT Edge Devices

_PreRequisites__

The use of [direnv](https://direnv.net/) can help managing environment variables.

## Environment Variables

### Edge Device VM Creation

- GROUP: The resource group name where resources will deploy.
- HUB: The desired IoT Hub to connect the device to.
- DEVICE: A unique name to use as the IoT Edge Device


### Auto Provisioning

- ARM_TENANT_ID: Azure Tenant hosting the subscription
- ARM_SUBSCRIPTION_ID: Azure Subscription Id hosting IoT Resources
- ARM_CLIENT_ID: Azure Principal Application id with scope for working in the Resource Group
- ARM_CLIENT_SECRET: Azure Prinicpal Application secret



## Provision an IoT Edge VM

_Certificate Preperation__

Certificate creation is performed by the [iot-resources](https://github.com/danielscholl/iot-resources) repository.  This requires a edge device certificate and they need to manually be copied into the private directory using the following format.

- root.ca.cert.pem
- $DEVICE.cert.pem
- $DEVICE.key.pem

> The $DEVICE.cert.pem but be the full chain certificate to function properly.

```bash
GROUP=iot-edge ./provision.sh

# The server will install iotedge automatically but the certificates and configuration
# need to still be copied in after the server reboots as part of its build process.
ssh <ipaddress>

$edge>: sudo cp -r certs /etc/iotedge/
$edge>: sudo cp config.yaml /etc/iotedge/
$edge>: sudo systemctl stop iotedge
$edge>: sudo systemctl daemon-reload
$edge>: sudo systemctl start iotedge
```

## Localhost Docker Self Provisioning Edge

The script requires an .envrc file to set environment variables used in creating the x509 certs.

```bash
# Setup the Environment Variables
export ARM_SUBSCRIPTION_ID="<subscription>"
export ARM_TENANT_ID="<tenant>"
export ARM_CLIENT_ID="<client_id>"
export ARM_CLIENT_SECRET="<client_secret>"

# Project Settings
export GROUP="iot-edge"
export HUB=$(az iot hub list --resource-group $GROUP --query [].name -otsv)
export DEVICE="edge-device"
export REGISTRY_SERVER="localhost:5000"

# Start IoT Device as a Docker Service
docker-compose -p iotedge up -d

# Stop the IoT Device Container
docker-compose -p iotedge stop
docker-compose -p iotedge rm --force
```




```bash
# Start IoT Edge as a Docker Container
docker-compose -p edge up -d

# Stop the IoT Edge Docker Container
docker-compose -p edge stop
docker-compose -p edge rm --force
```
