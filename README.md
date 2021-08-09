# Create an EtherLite validator node on [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server Ubuntu 20.04

## BEFORE YOU BEGIN, YOU WILL NEED:
100000 EtherLite (ETL)
A command line program e.g. http://www.putty.org
A [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server with Ubuntu 20.04
An ability to follow instructions to the letter!!!
Be aware, you are setting up a Validator Node on a remote server, and keeping your EtherLite Coins on a local MetaMask wallet. Your EtherLite Coins are never in danger from the remote server

### You are now ready to configure your Server!

Recommended Server Size: 2 CPU with 2GB of RAM and 80+ GB SSD (will work on 1GB of RAM with a SWAP file see below)

If you have < 2GB of RAM on the system. We’ll have to set up a swapfile. If you have the required 2GB, feel free to skip to next step.

   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   sudo sysctl vm.swappiness=10
   sudo sysctl vm.vfs_cache_pressure=50
   ```

1. Install Docker Engine and Docker Compose

   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   
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
