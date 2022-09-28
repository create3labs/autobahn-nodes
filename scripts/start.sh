#!/bin/bash

set -exEuo pipefail;

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

cd "${workdir}";
read -r -p "Stop everything before restarting (y/n)?" STOP_ALL;
if [ "$STOP_ALL" = "y" ]; then
  $compose_cmd down --remove-orphans;
fi

read -r -p "Start a member node? (y/n)?" START_MEMBERNODE;
if [ "$START_MEMBERNODE" = "y" ]; then
    if [ ! -f "${workdir}/nodes/member/.env" ]; then
      echo "${workdir}/nodes/member/.env missing. Please run the init.sh script first...";
      exit 1;
    fi

    $compose_cmd --profile service-node up -d;
    echo "Ok. Service Node is running...";
    exit 0;
else
    echo "Ok. Next...";
fi

read -r -p "Start a rpc node? (y/n)?" START_RPCNODE;
if [ "$START_RPCNODE" = "y" ]; then
    if [ ! -f "${workdir}/nodes/service/.env" ]; then
      echo "${workdir}/nodes/service/.env missing. Please run the init.sh script first...";
      exit 1;
    fi

    $compose_cmd --profile service-node up -d;
    echo "Ok. Service Node is running...";
    exit 0;
else
    echo "Ok. Next...";
fi