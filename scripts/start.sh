#!/bin/bash

set -exEuox pipefail;

( docker compose version 2>&1 || docker-compose version 2>&1 ) | grep -q v2 || { echo "docker compose v2 is required to run this script"; exit 1; };
compose_cmd="$(docker compose version 2>&1 | grep -q v2 && echo 'docker compose' || echo 'docker-compose')";

run_geth-cli_cmd () {
  local cmd="$1";
  local args="${*:2}";
  $compose_cmd --profile cli run geth-cli "$cmd" $args;
}

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../docker" &> /dev/null && pwd )";
cd "${workdir}";
source .env;

if [ -z ${NETWORK+x} ]; then
  echo "setting network to mainnet as default..."
  export NETWORK=autobahn;
fi

if [ -z ${HOME+x} ]; then
  echo "Please set HOME to your home dir...";
  exit 1;
fi

NODE_TYPE=$1;
if [ -z ${NODE_TYPE+x} ]; then
  NODE_TYPE="member";
fi

DATA_DIR=${HOME}/data/${NETWORK};
CONFIG_DIR=${HOME}/config/${NETWORK};

if [ ! -d "${DATA_DIR}" ]; then
  echo "${DATA_DIR} missing. Please run the init.sh script first...";
  exit 1;
fi

if [ ! -d "${CONFIG_DIR}" ]; then
  echo "${CONFIG_DIR} missing. Please run the init.sh script first...";
  exit 1;
fi

if [ ! -f "${CONFIG_DIR}/genesis.json" ]; then
  echo "${CONFIG_DIR}/genesis.json missing. Please run the init.sh script first...";
  exit 1;
fi

# fetch latest image
docker pull ghcr.io/rocknitive/geth_c3:main

cd "${workdir}";
read -r -p "Stop everything before restarting (y/n)?" STOP_ALL;
if [ "$STOP_ALL" = "y" ]; then
  $compose_cmd down --remove-orphans;
fi

if [ ! -f "${workdir}/nodes/${NODE_TYPE}/.env" ]; then
  echo "${workdir}/nodes/${NODE_TYPE}/.env missing. Please run the init.sh script first...";
  exit 1;
fi

case "$NODE_TYPE" in
"boot")
    $compose_cmd --profile bootnode up -d;
    echo "Boot Node is running...";
    ;;
"member")
    $compose_cmd --profile member-node up -d;
    echo "Member Node is running...";
    ;;
"service")
    $compose_cmd --profile service-node up -d;
    echo "Service Node is running...";
    ;;
"signer")
    $compose_cmd --profile signer-node up -d;
    echo "Signer Node is running...";
    ;;
"archive")
    $compose_cmd --profile archive-node up -d;
    echo "Archive Node is running...";
    ;;
*)
    echo "NODE_TYPE ${NODE_TYPE} is unknown.";
    exit 1;
    ;;
esac