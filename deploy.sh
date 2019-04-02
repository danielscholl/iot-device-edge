#!/usr/bin/env bash
#
#  Purpose: Initialize the environment
#  Usage:
#    deploy.sh

###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: deploy.sh" 1>&2; exit 1; }

if [ ! -z $1 ]; then EDGE_VM=$1; fi
if [ -z $EDGE_VM ]; then
  EDGE_VM="edge-device"
fi

if [ -z $HUB ]; then
  usage
fi

printf "\n"
tput setaf 2; echo "Deploying modules to ${EDGE_VM}" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0

az iot edge set-modules \
  --device-id ${EDGE_VM} \
  --hub-name $HUB \
  --content manifest.json
