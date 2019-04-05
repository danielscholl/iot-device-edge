#!/usr/bin/env bash
#
#  Purpose: Initialize the environment
#  Usage:
#    deploy.sh

###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: deploy.sh" 1>&2; exit 1; }

if [ ! -z $1 ]; then DEVICE=$1; fi
if [ -z $EDGE_VM ]; then
  DEVICE="edge"
fi

if [ -z $HUB ]; then
  usage
fi

printf "\n"
tput setaf 2; echo "Deploying modules to ${DEVICE}" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

az iot edge set-modules \
  --device-id ${DEVICE} \
  --hub-name $HUB \
  --content config/deployment.amd64.json
