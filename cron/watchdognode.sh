#!/bin/bash
if pgrep openethereum >/dev/null
then
	echo "Process is running."
else
	cd /root/validator-node-dockerized/ && screen -m -d -S node ./openethereum --config=node.toml --jsonrpc-port=8545 --jsonrpc-cors=all --jsonrpc-interface=all --jsonrpc-hosts=all --jsonrpc-apis=web3,eth,net,parity --ws-interface=all --ws-apis=web3,eth,net,parity,pubsub --ws-origins=all --ws-hosts=all --ws-max-connections=10 --max-peers=100
fi
