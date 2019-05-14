#!/usr/bin/env bash
#
#  Purpose: Create a Resource Group an Edge VM deployed to it
#  Usage:
#    get-cert.sh


###############################
## ARGUMENT INPUT            ##
###############################

if [ -f ./.envrc ]; then source ./.envrc; fi

if [ -z $GROUP ]; then echo "GROUP={resource_group} not set" \ exit 1; fi
if [ -z $DEVICE ]; then DEVICE=$1; fi
if [ -z $DEVICE ]; then echo "DEVICE={cert_name} not set" \ exit 1; fi
if [ -z $VAULT ]; then VAULT=$(az keyvault list --resource-group $GROUP --query [].name -otsv); fi

if [ -z $ORGANIZATION ]; then ORGANIZATION="myorg"; fi


printf "\n"
tput setaf 2; echo "Removing Old Certificates" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
rm -f cert/*.pem

printf "\n"
tput setaf 2; echo "Retrieving Required Certificates" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

# Download Root CA Certificate
az keyvault certificate download --name ${ORGANIZATION}-root-ca --vault-name $VAULT --file cert/root-ca.pem --encoding PEM

# Download and extract PEM files for Device
az keyvault secret download --name $DEVICE --vault-name $VAULT --file cert/$DEVICE.pem --encoding base64
openssl pkcs12 -in cert/$DEVICE.pem -out cert/$DEVICE.cert.pem -nokeys -passin pass:
openssl pkcs12 -in cert/$DEVICE.pem -out cert/$DEVICE.key.pem -nodes -nocerts -passin pass:
rm cert/$DEVICE.pem
