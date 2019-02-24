#!/usr/bin/env bash
#
#  Purpose: BootStrap Azure IoT Edge Server
#  Usage:
#    bootstrap.sh

logFile=/var/log/azure/installedge.log

echo "bootscript initiated" > $logFile

# Install repository configuration
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > ./microsoft-prod.list
sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
echo "Repository Configuration done" >> $logFile

# Install Microsoft GPG public key
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/
echo "GPS Public Key done" >> $logFile

# Perform apt update
sudo apt-get update -y
echo "Packages Update done" >> $logFile

# Install Package Dependencies
sudo apt-get install \
  apt-transport-https \
  ca-certificates curl \
  software-properties-common \
  -y >> $logFile 2>&1
echo "Package Dependencies done" >> $logFile

# Install Containerd
sudo apt-get install \
  moby-engine \
  moby-cli \
  -y >> $logFile 2>&1
# usermod -aG docker $(whoami) >> /tmp/results.txt 2>&1
echo "Install Containerd and Azure CLI done" >> $logFile

# Install Azure CLI
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
  --keyserver packages.microsoft.com \
  --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
sudo apt-get update
sudo apt-get install azure-cli -y >> $logFile 2>&1

# Install IotEdge
az extension add --name azure-cli-iot-ext >> $logFile 2>&1
sudo apt-get install iotedge -y >> $logFile 2>&1
echo "IotEdge done" >> $logFile

echo "bootscript done" >> $logFile

sudo shutdown -Fr now
exit 0
