#!/bin/bash
# passwd
# git clone https://github.com/antares-etherlite/etl-val-node
# cd etl-val-node
# chmod +x install.sh
# install.sh

sudo apt-get update && sudo apt-get -y upgrade

echo "Make swap..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

sudo systemctl disable rsyslog.service

cd ~/root/etl-val-node

curl -SfL "https://github.com/openethereum/openethereum/releases/download/v3.2.2-rc.1/openethereum-linux-v3.2.2-rc.1.zip" -o openethereum.zip

apt install -y unzip

unzip openethereum.zip

chmod +x openethereum

_rpcPassword=$(head /dev/urandom | tr -dc A-Z0-9 | head -c 12 ; echo '') && echo ${_rpcPassword} > password

_PUB_KEY=$(./openethereum account new --keys-path=data/keys --password=password --chain=genesis.json)

echo '#### File node.toml

[parity]
chain = "genesis.json"
base_path = "/root/etl-val-node/data"

[network]
port = 30300
discovery = true
interface = "local"

bootnodes = [
"enode://6c4f09592828d1a8014ca566cf42d4125e84bc35c8ee3cd9fd87cd13ac7a701ca2ecc2a9fb3727a3dd3a5ae1a1c0a8459ac1e4504707c837b7d8a3a27bd12d03@54.193.219.155:30300",
"enode://4200e5a56fb81ba1921e930504f950af3235d1b8dbcd1a5e3a2b6d934926c5a986b29e0ad3949c5d0cc37a2a4765a06b73d3b1b3314addf87a09b315c0cacdce@52.47.173.181:30300",
"enode://636195def83d3a5c420eaf5907549391f6702c1fd0c85b66a419b90b6af7908754aceaaa911236b5d0660a184960aab5b7785a6c87455d861c29cc76c0ba9fb6@65.1.219.106:30300",
"enode://f8fdeb5647ff32694029925ca79aeb50a61345f60a49cb264feb3d2f8bad7ea61774e9e52f683e7e4ada43aedbec97318cf4fd7cf349e82963df95ddfa9dfa25@52.197.202.193:30300",
"enode://60bc0c4678fcb6691b28a7a6480dd5b0f33681cd0eca1fd245e3ae4542831e2a9d9e11a43afcfa1821f667d583eab73a3ce66040a7268278ae3e8847c3902df6@3.96.25.239:30300",
"enode://360989533f9b9436275833d1f83b58629482ce6df8645890bb95c64f0badabc7a55989e553b7c18253ee880c1608e72b7327856502b710443352df52cd6efbea@35.72.213.63:30300",
"enode://7f373e2d9921f644cfe716d5b7410485463f17dbe0f6383b1082d1bfacf42f13ebba97d45921a0de58b83ad54c861ecc052e733a1db9449fb758d3d0be78b016@35.73.116.213:30300"
]

[rpc]
port = 8545
apis = ["eth","net"]
cors = ["*"]

[websockets]
port = 8546
[account]
password = ["/root/etl-val-node/password"]
unlock = ["$_PUB_KEY"]
[mining]
engine_signer = "$_PUB_KEY"
reseal_on_txs = "none"
force_sealing = true
' > node.toml
cd

_MON_IP=$(hostname -I)

echo '$_PUB_KEY,$_rpcPassword
' > $_MON_IP.csv
cd

sudo apt install fail2ban

cp jail.local /etc/fail2ban

sudo systemctl restart fail2ban

sudo ufw allow 30300
sudo ufw allow 30303
sudo ufw allow 30301
sudo ufw allow 8545
sudo ufw allow 8546
sudo ufw allow ssh
sudo ufw logging on
sudo ufw default allow outgoing
sudo ufw --force enable

crontab -l | { cat; echo "@reboot $HOME/etl-val-node/cron/watchdognode.sh > $HOME/etl-val-node/cron/watchdognode.log 2>&1"; } | crontab -

cd ~/root/etl-val-node

echo "Chain downloading..."
curl -L "https://fast.antarescodes.space/chains5798.zip" -o chains.zip
echo "Chain Unzip..."
unzip chains.zip

sleep 5

echo "Start Node..."
screen -m -d -S node ./openethereum --config=node.toml --jsonrpc-port=8545 --jsonrpc-cors=all --jsonrpc-interface=all --jsonrpc-hosts=all --jsonrpc-apis=web3,eth,net,parity --ws-interface=all --ws-apis=web3,eth,net,parity,pubsub --ws-origins=all --ws-hosts=all --ws-max-connections=5 --max-peers=30

# Reboot the server
# rm -v chains.zip
#reboot

