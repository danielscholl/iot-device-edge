# iot-edge

The purpose of this solution is to be able to easily deploy and run IoT Edge

```bash
./provision.sh

# SSH to the Edge Server and modify the configuration and restart
ssh <ipaddress>

$edge-vm: cp -r certs /etc/iotedge/
$edge-vm: cp config.yaml /etc/iotedge/
$edge-vm: sudo systemctl stop iotedge
$edge-vm: sudo systemctl daemon-reload
$edge-vm: sudo systemctl start iotedge

```


```bash
docker build -t iot-edge-device .
docker run -it --privileged \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e HUB=$HUB \
  iot-edge-device
```
