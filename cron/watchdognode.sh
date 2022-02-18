#!/bin/bash
if pgrep openethereum >/dev/null
then
	echo "Process is running."
else
	cd /root/etl-val-node/ && screen -m -d -S node ./openethereum --config=node.toml --jsonrpc-port=8545 --jsonrpc-cors=all --jsonrpc-interface=all --jsonrpc-hosts=all --jsonrpc-apis=web3,eth,net,parity --ws-interface=all --ws-apis=web3,eth,net,parity,pubsub --ws-origins=all --ws-hosts=all --ws-max-connections=5 --max-peers=30
fi
