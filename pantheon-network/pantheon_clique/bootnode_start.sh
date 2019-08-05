#!/bin/sh

# Copyright 2018 ConsenSys AG.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
node_id=`hostname`

PUBLIC_KEYS_DIR=${PANTHEON_PUBLIC_KEY_DIRECTORY:=/opt/pantheon/public-keys/}
GENESIS_FILE_DIR=${PANTHEON_GENESIS_FILE_DIRECTORY:=/opt/pantheon/genesis/}
DATA_DIR=${PANTHEON_DATA_DIR:=/var/lib/pantheon/}

PANTHEON_BINARY="/opt/pantheon/bin/pantheon $@ --data-path=${DATA_DIR}"

PUBLIC_KEY_FILE="${PUBLIC_KEYS_DIR}bootnode_pubkey"
PUBLIC_ADDRESS_FILE="${PUBLIC_KEYS_DIR}bootnode_address"
PUBLIC_KEY_FILE_BY_ID="${PUBLIC_KEYS_DIR}${node_id}_pubkey"
PUBLIC_ADDRESS_FILE_BY_ID="${PUBLIC_KEYS_DIR}${node_id}_address"


GENESIS_TEMPLATE_FILE=${DATA_DIR}genesis.json.template
GENESIS_FILE=${GENESIS_FILE_DIR}genesis.json

# write pub key for making other nodes able to connect to bootnode
${PANTHEON_BINARY} public-key export --to="${PUBLIC_KEY_FILE}"
cp ${PUBLIC_KEY_FILE} ${PUBLIC_KEY_FILE_BY_ID}

# get address for genesis
raw_address=`${PANTHEON_BINARY} public-key export-address --to="${PUBLIC_ADDRESS_FILE}"`
bootnode_address=`sed 's/^0x//' ${PUBLIC_ADDRESS_FILE}`
cp ${PUBLIC_ADDRESS_FILE} ${PUBLIC_ADDRESS_FILE_BY_ID}

# remove database as exporting public keys init the db but we don't have the right genesis yet
rm -Rf ${DATA_DIR}/database

# replace placeholder by address in genesis
sedCommand="s/<EXTRA_DATA_ADDRESSES>/${bootnode_address}/g"
sed ${sedCommand} ${GENESIS_TEMPLATE_FILE} > ${GENESIS_FILE}

# run bootnode with discovery but no bootnodes as it's our bootnode.
${PANTHEON_BINARY} --genesis-file="${GENESIS_FILE}"
