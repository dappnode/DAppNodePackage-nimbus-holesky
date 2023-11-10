#!/bin/bash

NETWORK="holesky"
VALIDATOR_PORT=3500

DATA_DIR="/home/user/nimbus-eth2/build/data"
VALIDATORS_DIR="${DATA_DIR}/validators"
TOKEN_FILE="${DATA_DIR}/auth-token"

# Create validators dir
mkdir -p ${VALIDATORS_DIR}

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY in
"holesky-geth.dnp.dappnode.eth")
    echo "Using holesky-geth.dnp.dappnode.eth"
    HTTP_ENGINE="http://holesky-geth.dappnode:8551"
    ;;
"holesky-nethermind.dnp.dappnode.eth")
    echo "Using holesky-nethermind.dnp.dappnode.eth"
    HTTP_ENGINE="http://holesky-nethermind.dappnode:8551"
    ;;
"holesky-besu.dnp.dappnode.eth")
    echo "Using holesky-besu.dnp.dappnode.eth"
    HTTP_ENGINE="http://holesky-besu.dappnode:8551"
    ;;
"holesky-erigon.dnp.dappnode.eth")
    echo "Using holesky-erigon.dnp.dappnode.eth"
    HTTP_ENGINE="http://holesky-erigon.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY"
    HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY
    ;;
esac

#Handle Graffiti Character Limit
oLang=$LANG oLcAll=$LC_ALL
LANG=C LC_ALL=C
graffitiString=${GRAFFITI:0:32}
LANG=$oLang LC_ALL=$oLcAll

# Run checkpoint sync script if provided
[[ -n $CHECKPOINT_SYNC_URL ]] &&
    /home/user/nimbus-eth2/build/nimbus_beacon_node trustedNodeSync \
        --network=${NETWORK} \
        --trusted-node-url=${CHECKPOINT_SYNC_URL} \
        --backfill=false \
        --data-dir=${DATA_DIR}

[[ -n $WEB3_BACKUP_URL ]] && EXTRA_OPTS="--web3-url=${WEB3_BACKUP_URL} ${EXTRA_OPTS}"

exec -c /home/user/nimbus_beacon_node \
    --network=${NETWORK} \
    --data-dir=${DATA_DIR} \
    --tcp-port=$P2P_TCP_PORT \
    --udp-port=$P2P_UDP_PORT \
    --validators-dir=${VALIDATORS_DIR} \
    --log-level=${LOG_TYPE} \
    --rest \
    --rest-port=4500 \
    --rest-address=0.0.0.0 \
    --metrics \
    --metrics-address=0.0.0.0 \
    --metrics-port=8008 \
    --keymanager \
    --keymanager-port=${VALIDATOR_PORT} \
    --keymanager-address=0.0.0.0 \
    --keymanager-token-file=${TOKEN_FILE} \
    --graffiti="${graffitiString}" \
    --jwt-secret=/jwtsecret \
    --web3-url=$HTTP_ENGINE \
    --suggested-fee-recipient="${FEE_RECIPIENT_ADDRESS}" \
    $EXTRA_OPTS
