# How to Create a Etherlite validator node on VULTR or DIGITAL OCEAN server with Ubuntu 20.04

1. Install Docker Engine and Docker Compose

   ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    curl https://get.docker.com | sh
    sudo usermod -aG docker $USER
    sudo reboot
   ```

2. Clone this repo:

   ```bash
    git clone https://github.com/antares21scorpi/validator-node-dockerized
    cd validator-node-dockerized
   ```

3. Download the OpenEthereum From EtherLite Releases.

   ```bash
   curl -L "https://github.com/etherlite-org/openethereum/releases/download/v3.2.2-rc.1/openethereum-ubuntu20.04.zip" -o openethereum.zip
   ```

4. Install unzip to unzip the downloaded OpenEthereum zip.

   ```bash
   apt install -y unzip
   ```

5. Unzip the OpenEthereum zip
   ```bash
   unzip openethereum.zip
   ```
6. Create password file for mining account.
   ```bash
   echo "YOUR-VAL-UNIQUE-PASS" > password
   ```
7. Create your mining account

   ```bash
   ./openethereum account new --keys-path=data/keys --password=password --chain=etherlite
   ```

8. Copy `.env.example` to `.env`

   ```bash
   cp .env.example .env
   ```

9. Configure the `.env` file. There are a few settings you need to define:

   ```
   PASSWORD_PATH=/root/password
   EXT_IP=YOUR-EXTERNAL-IP-ADDRESS
   ACCOUNT=0x...
   ```

   - `EXT_IP` - External IP of the current server.
   - `ACCOUNT` - Your mining address (with leading `0x`).

10. Start your node.

    ```bash
    docker-compose up -d
    ```

After docker containers are created, the node will sync with the chain (may take a while).

To restart you need to use `docker-compose stop` and `docker-compose start` being in the `validator-node-dockerized` directory.
