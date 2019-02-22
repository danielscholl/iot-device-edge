#!/usr/bin/env bash
#
#  Purpose: Create a Resource Group an Edge VM deployed to it
#  Usage:
#    get-cert.sh


###############################
## ARGUMENT INPUT            ##
###############################

usage() { echo "Usage: get-cert.sh " 1>&2; exit 1; }

if [ -f ./.envrc ]; then source ./.envrc; fi

if [ -z $1 ]; then
  GROUP="iot-resources"
else
  GROUP=$1
fi

if [ -z $2 ]; then
  VAULT=$(az keyvault list --resource-group $GROUP --query [].name -otsv)
else
  VAULT=$2
fi

printf "\n"
tput setaf 2; echo "Retrieving Required Certificates" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

# Download Root CA Certificate
az keyvault certificate download --name testonly-root-ca --vault-name $VAULT -f cert/root-ca.cert.pem

# Download and extract PEM files for Device
az keyvault secret download --name $DEVICE --vault-name $VAULT --file cert/$DEVICE.pem --encoding base64
openssl pkcs12 -in cert/$DEVICE.pem -out cert/$DEVICE.cert.pem -nokeys -passin pass:
openssl pkcs12 -in cert/$DEVICE.pem -out cert/$DEVICE.key.pem -nodes -nocerts -passin pass:
rm cert/$DEVICE.pem

