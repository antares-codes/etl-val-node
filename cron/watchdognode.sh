#!/bin/bash
if pgrep openethereum >/dev/null
then
	echo "Process is running."
else
	cd /root/validator-node-dockerized/ && docker-compose start
fi
