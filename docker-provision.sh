#!/bin/bash

function provisionResources()
{
  tput setaf 2; echo "Authenticating the CLI" ; tput sgr0
  tput setaf 3; echo "------------------------------------" ; tput sgr0
  az login \
    --service-principal \
    --username $ARM_CLIENT_ID \
    --password $ARM_CLIENT_SECRET \
    --tenant $ARM_TENANT_ID \
    -oyaml

  az account set \
    --subscription $ARM_SUBSCRIPTION_ID -oyaml


  tput setaf 2; echo "Creating IoT Edge Device" ; tput sgr0
  tput setaf 3; echo "------------------------------------" ; tput sgr0
  az iot hub device-identity create \
    --device-id $(hostname) \
    --hub-name $HUB \
    --edge-enabled \
    -oyaml

  HUB_CONNECTION_STRING=$(az iot hub device-identity show-connection-string \
                            --device-id $(hostname) \
                            --hub-name $HUB \
                            -otsv)
  az iot hub device-twin update \
    --device-id $(hostname) \
    --hub-name $HUB \
    --set tags='{"environment":"'$ENVIRONMENT'"}' \
    -oyaml
}

function startEdgeRuntime()
{
  tput setaf 2; echo "Configure and Start IoT Edge Runtime" ; tput sgr0
  tput setaf 3; echo "------------------------------------" ; tput sgr0


  IP=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

  echo export IOTEDGE_HOST=http://$IP:15580 >> ~/.bashrc

cat <<EOF > /etc/iotedge/config.yaml
provisioning:
  source: "manual"
  device_connection_string: "$HUB_CONNECTION_STRING"
agent:
  name: "edgeAgent"
  type: "docker"
  env: {}
  config:
    image: "mcr.microsoft.com/azureiotedge-agent:1.0"
    auth: {}
hostname: $(cat /proc/sys/kernel/hostname)
connect:
  management_uri: "http://$IP:15580"
  workload_uri: "http://$IP:15581"
listen:
  management_uri: "http://$IP:15580"
  workload_uri: "http://$IP:15581"
homedir: "/var/lib/iotedge"
moby_runtime:
  docker_uri: "/var/run/docker.sock"
  network: "azure-iot-edge"
EOF

  iotedged -c /etc/iotedge/config.yaml
}

tput setaf 2; echo "Startup Docker In Docker" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

#remove docker.pid if it exists to allow Docker to restart if the container was previously stopped
if [ -f /var/run/docker.pid ]; then
    echo "Stale docker.pid found in /var/run/docker.pid, removing..."
    rm /var/run/docker.pid
fi

dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

while (! docker stats --no-stream ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  sleep 1
done

if [ -z "$HUB_CONNECTION_STRING" ]; then
    echo "No connectionString provided, provisioning as a new IoTEdge device with name: $(hostname)"
    provisionResources
fi
startEdgeRuntime
