# DO NOT USE THIS GUIDE - UNDER CONSTRUCTION

# Create an EtherLite validator node on [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server Ubuntu 20.04

### Watch full video procedure on [YouTube EtherLite UnOfficial](https://youtu.be/1BcjqPp10iY)

## BEFORE YOU BEGIN, YOU WILL NEED:
- 100000 EtherLite (ETL)
- A command line program e.g. http://www.putty.org
- A [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) server with Ubuntu 20.04
- An ability to follow instructions to the letter!!!
- Additional Support by Antares [Discord Channel](https://discord.gg/uHEVyRc6Zb) and/or [Telegram Channel](https://t.me/etherlite_stakvaldev)
- Be aware, you are setting up a Validator Node on a remote server, and keeping your EtherLite Coins on a local MetaMask wallet. Your EtherLite Coins are never in danger from the remote server

### You are now ready to configure your Server!

Recommended Server Size: 2 CPU Premium Intel/AMD (Digital Ocean) or High Frequency (VULTR) with 2GB of RAM and 60+GB SSD. Note that you will have to Resize/Upgrade you Droplet/Server over time as the Blockchain will increase in size as well as the number of transactions per block.

1. Update and Upgrade your server.

   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

2. Sync Clock:

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
   
3. Clone this repo:

   ```bash
   git clone https://github.com/antares-etherlite/validator-node-screen
   cd validator-node-screen
   ```

4. Download the OpenEthereum From EtherLite Releases.

   ```bash
   curl -L "https://github.com/openethereum/openethereum/releases/download/v3.2.2-rc.1/openethereum-linux-v3.2.2-rc.1.zip" -o openethereum.zip
   ```

5. Install unzip to unzip the downloaded OpenEthereum zip.

   ```bash
   apt install -y unzip
   ```

6. Unzip the OpenEthereum zip
   ```bash
   unzip openethereum.zip
   ```
7. Create password file for mining account.
   ```bash
   echo "YOUR-VAL-UNIQUE-PASS" > password
   ```
8. Create your mining account

   ```bash
   ./openethereum account new --keys-path=data/keys --password=password --chain=etherlite
   ```
   Save the return address for stept 11

9. Copy `.env.example` to `.env`

    ```bash
    cp .env.example .env
    ```

10. Update `.env` file. There are a few settings you need to define:

    ```bash
    nano .env
   
    Update Parameter below.
   
    EXT_IP=YOUR-EXTERNAL-IP-ADDRESS
    ACCOUNT=0x...
    ```

    - `EXT_IP` - External IP of the current server.
    - `ACCOUNT` - Your mining address (with leading `0x`).

11. Start your node.

     ```bash
     screen -S node
     ./openethereum --config=node.toml --jsonrpc-port=8545 --jsonrpc-cors=all --jsonrpc-interface=all --jsonrpc-hosts=all --jsonrpc-apis=web3,eth,net,parity --ws-interface=all --ws-apis=web3,eth,net,parity,pubsub --ws-origins=all --ws-hosts=all --ws-max-connections=10 --max-peers=100
     ```

     The node will sync with the chain (may take a while, 3+ hours).

     To safely minimize the screen by entering (CTRL+a+d)

12. Check if sync is completed.

     ```bash
     curl --data '{"method":"eth_syncing","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
     ```
    
     This is what you're waiting to see: {"jsonrpc":"2.0","result":false,"id":1}
     
11. Stop your node.
     
     First you need to find your Screen ID
     
     ```bash
     screen -list
     ```

     You will get back something like below.
     
     > There is a screen on:
            5182.node       (10/16/2021 03:02:40 PM)        (Detached)
     1 Socket in /run/screen/S-root.

     Your Screen ID is 5182.node. (replace 5182 with your ID)
     
      ```bash
     screen -X -S "5182.node" quit
     ```
     
     Or if you just want to get back to monitor your node. (replace 5182 with your ID)
     
      ```bash
     screen -r 5182.node
     ```

13. Security.

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

14. Setup Monitoring with a crontab entry. (If your node go offline, it will restart automatically.)

     ```bash
     sudo chmod 755 /root/validator-node-dockerized/cron/watchdognode.sh
     crontab -e
    
     Add this line to the end of the file plus(+) a carriage return(blank line). save and exit.
    
     * * * * * $HOME/validator-node-dockerized/cron/watchdognode.sh > $HOME/validator-node-dockerized/cron/watchdognode.log 2>&1
     ```
     
     (Optional) Monitor all your nodes with [Site24x7](https://www.site24x7.com). Receive Server Down, Critical or Trouble SMS/eMail alerts.
     
15. Double check if your validator node is working after ReBooting before you submit it to https://staking.etherlite.org

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
    
    Join our [Discord Support Channel](https://discord.gg/uHEVyRc6Zb) and/or [Telegram Channel](https://t.me/etherlite_stakvaldev)
    
    Manage Social, Meeting, Chat, CRM, Helpdesk, Mails, Apps, Files, Sales & Marketing with [ZOHO](https://go.zoho.com/Jfo)
