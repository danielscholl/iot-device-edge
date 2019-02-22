# iot-device-edge

The purpose of this solution is to be able to easily deploy and run IoT Edge Devices

__PreRequisites__

Requires the use of [direnv](https://direnv.net/).  
Requires the use of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).  
Requires the use of [Docker](https://www.docker.com/get-started).  

### Related Repositories

- [iot-resources](https://github.com/danielscholl/iot-resources)  - Deploying IoT Resources and x509 Management
- [iot-device-edge](https://github.com/danielscholl/iot-device-edge) - Simple Edge Testing
- [iot-device-js](https://github.com/danielscholl/iot-device-js) - Simple Device Testing
- [iot-control-js](https://github.com/danielscholl/iot-control-js) - Simple Control Testing


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

This requires a edge device certificates to have been created from [iot-resources](https://github.com/danielscholl/iot-resources).

- root-ca.cert.pem
- $DEVICE.cert.pem  ** THIS IS THE FULL CHAIN CERT **
- $DEVICE.key.pem


```bash
DEVICE="edge-device" ./device-cert.sh
DEVICE="edge-device" ./provision.sh

# The server will install iotedge automatically but the certificates and configuration
# need to be copied into place and the service restarted.
ssh <ipaddress> init.sh
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

## Run in Swarm as a Stack
Would be nice but can not run due to no Swarm privileged mode yet
```
