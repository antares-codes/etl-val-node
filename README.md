# Create an EtherLite validator node on [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server Ubuntu 20.04

### Video Coming Soon on [YouTube EtherLite UnOfficial](https://www.youtube.com/c/EtherLite/videos)

## BEFORE YOU BEGIN, YOU WILL NEED:
- 100000 EtherLite (ETL)
- A command line program e.g. http://www.putty.org
- A [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server with Ubuntu 20.04
- An ability to follow instructions to the letter!!!
- Additional Support by Antares [Discord Channel](https://discord.gg/uHEVyRc6Zb)
- Be aware, you are setting up a Validator Node on a remote server, and keeping your EtherLite Coins on a local MetaMask wallet. Your EtherLite Coins are never in danger from the remote server

### You are now ready to configure your Server!

Recommended Server Size: 2 CPU Premium Intel/AMD or High Frequency with 2GB of RAM and 60+GB SSD (will work on 1GB of RAM with a SWAP file "NOT Recommended" see below) Note that you will have to Resize/Upgrade you Droplet/Server over time as the Blockchain will increase in size as well as the number of transactions per block.

1. If you have < 2GB of RAM on the system "NOT Recommended". We’ll have to set up a swapfile. If you have the required 2GB, feel free to skip to next step.

   We can see if the system has any configured swap by typing:

   ```bash
   sudo swapon --show
   ```
 
   If you don’t get back any output, this means your system does not have swap space, follow procedure below.

   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   sudo sysctl vm.swappiness=10
   sudo sysctl vm.vfs_cache_pressure=50
   ```

2. Install Docker Engine and Docker Compose

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

3. Sync Clock:

   Your clock should by synchronized to prevent skipping block sealing.

   Enter `timedatectl status` , you should see similar output:

   ```bash
   Local time: Tue 2020-06-30 17:16:19 UTC
   Universal time: Tue 2020-06-30 17:16:19 UTC
   RTC time: Tue 2020-06-30 17:16:19
   Time zone: Etc/UTC (UTC, +0000)
   System clock synchronized: yes
   systemd-timesyncd.service active: yes
   RTC in local TZ: no
   ```
   If System clock synchronized displays yes and Time zone is set to UTC, proceed to step 4.
   
   If not, get help here: https://vitux.com/how-to-sync-system-time-with-internet-time-servers-on-ubuntu-20-04/
   
4. Clone this repo:

   ```bash
   git clone https://github.com/antares-etherlite/validator-node-dockerized
   cd validator-node-dockerized
   ```

5. Download the OpenEthereum From EtherLite Releases.

   ```bash
   curl -L "https://github.com/etherlite-org/openethereum/releases/download/v3.2.2-rc.1/openethereum-ubuntu20.04.zip" -o openethereum.zip
   ```

6. Install unzip to unzip the downloaded OpenEthereum zip.

   ```bash
   apt install -y unzip
   ```

7. Unzip the OpenEthereum zip
   ```bash
   unzip openethereum.zip
   ```
8. Create password file for mining account.
   ```bash
   echo "YOUR-VAL-UNIQUE-PASS" > password
   ```
9. Create your mining account

   ```bash
   ./openethereum account new --keys-path=data/keys --password=password --chain=etherlite
   ```
   Save the return address for stept 11

10. Copy `.env.example` to `.env`

    ```bash
    cp .env.example .env
    ```

11. Update `.env` file. There are a few settings you need to define:

    ```bash
    nano .env
   
    Update Parameter below.
   
    EXT_IP=YOUR-EXTERNAL-IP-ADDRESS
    ACCOUNT=0x...
    ```

    - `EXT_IP` - External IP of the current server.
    - `ACCOUNT` - Your mining address (with leading `0x`).

12. Start your node.

     ```bash
     docker-compose up -d
     ```

     After docker containers are created, the node will sync with the chain (may take a while, 3+ hours).

     To restart you need to use `docker-compose stop` and `docker-compose start` being in the `validator-node-dockerized` directory.

13. Check if sync is completed.

     ```bash
     curl --data '{"method":"eth_syncing","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
     ```
    
     This is what you're waiting to see: {"jsonrpc":"2.0","result":false,"id":1}

14. Security.

     There is no need to setup a UFW firewall (There are too many ports to allow for communication between nodes)

     So make sure it is Offline. (There is nothing of value anyway, unless you are running other scripts with your EtherLite Node, Not recommended)
     
     ```bash
     sudo ufw status
     ```
     
     You should get "Status: inactive"
     
     If not type: 
     
     ```bash
     sudo ufw disable
     ```

     (Optional) We recommend you to install [Fail2ban](https://linuxize.com/post/install-configure-fail2ban-on-ubuntu-20-04/) to avoid brute force attack.

15. Setup Monitoring with a crontab entry. (If your node go offline, it will restart automatically.)

     ```bash
     sudo chmod 755 /root/validator-node-dockerized/cron/watchdognode.sh
     crontab -e
    
     Add this line to the end of the file plus(+) a carriage return(blank line). save and exit.
    
     * * * * * $HOME/validator-node-dockerized/cron/watchdognode.sh > $HOME/validator-node-dockerized/cron/watchdognode.log 2>&1
     ```
     
     (Optional) Monitor all your nodes with [Site24x7](https://www.site24x7.com). Receive Server Down, Critical or Trouble SMS/eMail alerts.
     
16. Double check if your validator node is working after ReBooting before you submit it to https://staking.etherlite.org

    ```bash
    sudo reboot
    ```
    
    Wait 2 minutes before login back in your server.
    
    ```bash
    curl --data '{"method":"eth_syncing","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
    ```
    
    Again, This is what you're waiting to see: {"jsonrpc":"2.0","result":false,"id":1}
    
    Next test if RPC communication is enabled with your server, type `http://YOUR-EXTERNAL-IP-ADDRES:8545` in any web browser.
    
    This is the message you're waiting to see: Used HTTP Method is not allowed. POST or OPTIONS is required
    
    Now you are ready to got to https://staking.etherlite.org. Just click the Become a Candidate Button and fill up the form.

    ## All done now! You are now a Validator Node Master...
    
    Join our [Discord Support Channel](https://discord.gg/uHEVyRc6Zb)
    
    Manage Social, Meeting, Chat, CRM, Helpdesk, Mails, Apps, Files, Sales & Marketing with [ZOHO](https://go.zoho.com/Jfo)
