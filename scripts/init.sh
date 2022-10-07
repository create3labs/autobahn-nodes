#!/bin/bash

set -eEuo pipefail;

( docker compose version 2>&1 || docker-compose version 2>&1 ) | grep -q v2 || { echo "docker compose v2 is required to run this script"; exit 1; };
compose_cmd="$(docker compose version 2>&1 | grep -q v2 && echo 'docker compose' || echo 'docker-compose')";

run_geth-cli_cmd () {
  local cmd="$1";
  local args="${*:2}";
  $compose_cmd --profile cli run geth-cli "$cmd" $args;
}

if [ -z ${NETWORK+x} ]; then
  echo "setting network to mainnet as default..."
  export NETWORK=autobahn;
fi

if [ -z ${HOME+x} ]; then
  echo "Please set HOME to your home dir...";
  exit 1;
fi

if [ -z ${INTERFACE+x} ]; then
  INTERFACE=eth0;
fi

DATA_DIR=${HOME}/data/${NETWORK};
CONFIG_DIR=${HOME}/config/${NETWORK};

echo "DATADIR ${DATA_DIR}...";
if [ ! -d "${DATA_DIR}" ]; then
  echo "Creating data dir...";
  mkdir -p ${DATA_DIR};
fi

echo "CONFIG_DIR ${CONFIG_DIR}...";
if [ ! -d "${CONFIG_DIR}"  ]; then
  echo "Creating config dir...";
  mkdir -p ${CONFIG_DIR};
fi

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../docker" &> /dev/null && pwd )";
cd "${workdir}";

if [ ! -f "${workdir}/.env"  ]; then
  echo "Copying the ${workdir}/.env.example to ${workdir}/.env...";
  cp ${workdir}/.env.example ${workdir}/.env;
fi

if [ ! -f "${workdir}/nodes/.env"  ]; then
  echo "Copying the ${workdir}/nodes/.env.example to ${workdir}/nodes/.env...";
  cp ${workdir}/nodes/.env.example ${workdir}/nodes/.env;
fi

if [ ! -f "${workdir}/nodes/member/.env"  ]; then
  echo "Copying the ${workdir}/nodes/member/.env.example to ${workdir}/nodes/member/.env...";
  cp ${workdir}/nodes/member/.env.example ${workdir}/nodes/member/.env;
fi

if [ ! -f "${workdir}/nodes/service/.env"  ]; then
  echo "Copying the ${workdir}/nodes/service/.env.example to ${workdir}/nodes/service/.env...";
  cp ${workdir}/nodes/service/.env.example ${workdir}/nodes/service/.env;
fi

if [ ! -f "${workdir}/nodes/signer/.env"  ]; then
  echo "Copying the ${workdir}/nodes/signer/.env.example to ${workdir}/nodes/signer/.env...";
  cp ${workdir}/nodes/signer/.env.example ${workdir}/nodes/signer/.env;
fi

if [ ! -f "${workdir}/nodes/boot/.env"  ]; then
  echo "Copying the ${workdir}/nodes/boot/.env.example to ${workdir}/nodes/boot/.env...";
  cp ${workdir}/nodes/boot/.env.example ${workdir}/nodes/boot/.env;
fi

if [ ! -f "${workdir}/nodes/archive/.env"  ]; then
  echo "Copying the ${workdir}/nodes/archive/.env.example to ${workdir}/nodes/archive/.env...";
  cp ${workdir}/nodes/archive/.env.example ${workdir}/nodes/archive/.env;
fi

source .env;
docker pull ghcr.io/rocknitive/geth_c3:main

# Set the correct rights (For docker setup)
$compose_cmd run init;

IP_ADDRESS=$(ip -4 addr show ${INTERFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}');
if [[ ! $IP_ADDRESS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    echo "Could not read IP_ADDRESS from ifconfig. This was not intended.";
    exit 1;
fi

echo "COPY the IP_ADDRESS to your ${workdir}/nodes/.env as STATIC_BOOTNODE_IP value...";
sed -i "/STATIC_BOOTNODE_IP.*/cSTATIC_BOOTNODE_IP=$IP_ADDRESS" ${workdir}/nodes/.env;

echo "We need a genesis.json...";
if [ ! -f "${CONFIG_DIR}/genesis.json"  ]; then
  echo "Copying the autobahn-genesis.json to ${CONFIG_DIR}/genesis.json...";
  cp ${workdir}/../autobahn-genesis.json ${CONFIG_DIR}/genesis.json;
  echo "It is necessary that all nodes of ONE chain use the SAME genesis file...";
fi

sleep 1;
echo "Please check the .env files in ${workdir}/nodes/**/.env and ${workdir}/.env...";
echo "After that, you can start the chain with ./scripts/start.sh...";
