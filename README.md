# Transfer your active EtherLite validator node to [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) or any root access server supporting Ubuntu 20.04

## BEFORE YOU BEGIN, YOU WILL NEED:
- An already active and running EtherLite Validator node.
- A command line program e.g. http://www.putty.org for OSX https://www.ssh.com/academy/ssh/putty/mac
- A [VULTR](https://www.vultr.com/?ref=6881736) or [DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2) or any root access server supporting Ubuntu 20.04
- An ability to follow instructions to the letter! If you run 2 nodes with same address you will get in trouble.
- Additional Support by Antares [Discord Channel](https://discord.gg/uHEVyRc6Zb) and/or [Telegram Channel](https://t.me/antarescodes)
- Be aware, you are setting up a Validator Node on a remote server, and keeping your EtherLite Coins on a local MetaMask wallet. Your EtherLite Coins are never in danger from the remote server

### You are now ready to configure your new Server!

Recommended Server Size: 2 CPU Premium Intel/AMD ([DIGITAL OCEAN](https://m.do.co/c/e2c65321d0d2)) or High Frequency ([VULTR](https://www.vultr.com/?ref=6881736)) with 2GB of RAM and 60+GB SSD. Note that you will have to Resize/Upgrade you Droplet/Server over time as the Blockchain will increase in size as well as the number of transactions per block.

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
   If System clock synchronized displays yes and Time zone is set to UTC, proceed to step 3.
   
   If not, get help here: https://vitux.com/how-to-sync-system-time-with-internet-time-servers-on-ubuntu-20-04/
   
3. Clone this repo:

   ```bash
   git clone https://github.com/antares-etherlite/validator-node-screen
   cd validator-node-screen
   ```

4. Download OpenEthereum.

   ```bash
   curl -SfL "https://github.com/openethereum/openethereum/releases/download/v3.2.2-rc.1/openethereum-linux-v3.2.2-rc.1.zip" -o openethereum.zip
   ```

5. Install unzip.

   ```bash
   apt install -y unzip
   ```

6. Unzip the OpenEthereum zip
   ```bash
   unzip openethereum.zip
   ```
7. Give proper permission to run the file
   ```bash
   chmod +x openethereum
   ```
8. Download the genesis file of EtherLite
   ```bash
   curl -SfL 'https://raw.githubusercontent.com/etherlite-org/openethereum/etherlite/crates/ethcore/res/chainspec/etherlite.json' -o genesis.json
   ```
9. Retreive your password from the old server with command `cat password` and Create password file for Validator account on the new server. Make sure your are in password directory.
   ```bash
   echo "YOUR-PASS-FROM-OLD-SERVER" > password
   ```
10. Retreive your Validator account address from the old server

    ```bash
    curl --data '{"method":"eth_accounts","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
    ```
    Save the returning address starting with 0x for stept 12
    
11. Transfer your Validator account address key to your new server (This is a tricky part, If you are not sure here contact Antares for support)

    PLAN A: For advance user to open any FTP program download your key from old server /data/keys/etl and upload to your new server /data/keys/etl.
    
    PLAN B: Newby not familiar with an FTP program.

    From your old server, this could be located in cd /opt/validator-node-dockerized/data/keys/etl or cd /root/validator-node-dockerized/data/keys/etl or cd /root/validator-node-screen/data/keys/etl depending on your initial setup.
    
    Just copy the long file name that look like "UTC--2021-08-18T11-05-28Z--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" and save in notepad for future use.
    
    Now retreive the data inside the file (change UTC key file name with your below)
    
    ```bash
    cat UTC--2021-08-18T11-05-28Z--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ```
    You will get something like this:
{"id":"XXXXXXXXXXXXXXXXXXXXXXXX","version":3,"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"34a77fbXXXXXXXXXXXXXXXXXX665ff"},"ciphertext":"719560d3aa8487a7a61XXXXXXXXXXXXXXXXXXXXXXXXXXXXX0edc4e5267feae65","kdf":"pbkdf2","kdfparams":{"c":10240,"dklen":32,"prf":"hmac-sha256","salt":"9fe1e0712c544XXXXXXXXXXXXXXXXXXXXXXXXXXX53a7b99f4b5ca"},"mac":"b0c617b6c06XXXXXXXXXXXXXXXXXXXXXXXXXXX3182ae282954e1825bb2bf7"},"address":"a6d721XXXXXXXXXXXXXXXXX XXXXXX89ec","name":"","meta":"{}"}

    Just copy all from the opening to the closing bracket.
    
    Going back to the new server. (change UTC key file name with your below)
    
    ```bash
    cd /root/validator-node-dockerized/data/keys/etl
    nano UTC--2021-08-18T11-05-28Z--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    Add the data we got previously like below but all should fit in one line with no space or carriage return. save and exit.
    
    {"id":"XXXXXXXXXXXXXXXXXXXXXXXX","version":3,"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"34a77fbXXXXXXXXXXXXXXXXXX665ff"},"ciphertext":"719560d3aa8487a7a61XXXXXXXXXXXXXXXXXXXXXXXXXXXXX0edc4e5267feae65","kdf":"pbkdf2","kdfparams":{"c":10240,"dklen":32,"prf":"hmac-sha256","salt":"9fe1e0712c544XXXXXXXXXXXXXXXXXXXXXXXXXXX53a7b99f4b5ca"},"mac":"b0c617b6c06XXXXXXXXXXXXXXXXXXXXXXXXXXX3182ae282954e1825bb2bf7"},"address":"a6d721XXXXXXXXXXXXXXXXX XXXXXX89ec","name":"","meta":"{}"}
    ```
    After Adding the data Press CTRL+X you will be asked if you want to save. Enter Y and Press Enter.

12. Update `node.toml` file. There are a few settings you need to define:

    ```bash
    cd /root/validator-node-dockerized/
    nano node.toml
   
    Update Parameter below.
   
    unlock = [""]
    engine_signer = ""
    ```
    - Line 31 `unlock` - Your account address (with leading `0x`).
    - Line 33 `engine_signer` - Your account address (with leading `0x`).

    After Adding your validator address Press CTRL+X you will be asked if you want to save. Enter Y and Press Enter.

13. (RECOMMENDED BUT OPTIONAL) Download a Blockchain snapshot for faster initial sync. Save 3+ hours of sync.
     
     Since synchronizing the blockchain can take many hours at this point, I decided to make a snapshot (around block height 3,748,000) so you can synchronize faster when setting up a new node - your node will only have to sync blocks made after that point. Make sure you are still in ~/validator-node-screen# directory before unziping.
     
     ```bash
     curl -L "https://fast.antarescodes.space/chains5798.zip" -o chains.zip
     unzip chains.zip
     ```
     
     NOTE: This file is 1.6 GB, download time may differ depending on your server performance and connection (usually under 30 seconds) this will save you 3+ hours of sync. The snapshot file is located on my personal high-speed space Digital Ocean paying account for better download performance speed.

14. Start your node. (Before you do that make sure your old validator node is not running. - Use command `docker-compose stop` or `screen -X -S "SCREEN-ID" quit`)

     ```bash
     screen -S node
     ./openethereum --config=node.toml --jsonrpc-port=8545 --jsonrpc-cors=all --jsonrpc-interface=all --jsonrpc-hosts=all --jsonrpc-apis=web3,eth,net,parity --ws-interface=all --ws-apis=web3,eth,net,parity,pubsub --ws-origins=all --ws-hosts=all --ws-max-connections=10 --max-peers=100
     ```

     The node will sync with the chain (may take a while).

     To safely minimize Screen by entering (CTRL+a+d)

15. Check if sync is completed.

     ```bash
     curl --data '{"method":"eth_syncing","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
     ```
    
     This is what you're waiting to see: {"jsonrpc":"2.0","result":false,"id":1}
     
16. (OPTIONAL SCREEN COMMAND) If you need to Stop your node.
     
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

17. Security.

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

18. Setup Monitoring with a crontab entry. If your node go offline, it will restart automatically. (NOTE: FOR crontab -e "select NANO 1")

     ```bash
     sudo chmod 755 /root/validator-node-screen/cron/watchdognode.sh
     crontab -e
    
     Add this line to the end of the file plus(+) a carriage return(blank line). save and exit.
    
     * * * * * $HOME/validator-node-screen/cron/watchdognode.sh > $HOME/validator-node-screen/cron/watchdognode.log 2>&1
     ```
     After Adding the cron line Press CTRL+X you will be asked if you want to save. Enter Y and Press Enter.
     
     (Optional) Monitor all your nodes with [Site24x7](https://www.site24x7.com). Receive Server Down, Critical or Trouble SMS/eMail alerts.
     
19. Double check if your validator node is working after ReBooting.

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

    ## All done now! Before you delete your old server, make sure your new node is validating blocks on the explorer: https://explorer.etherlite.org/
    
    Also double check that step 11 of transferring your key was done correctly.

    ```bash
    curl --data '{"method":"eth_accounts","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
    ```
    If you got back your validator node address key like on your old server, then your good to go.
    
    Join our [Discord Support Channel](https://discord.gg/uHEVyRc6Zb) and/or [Telegram Channel](https://t.me/antarescodes)
    
    Manage Social, Meeting, Chat, CRM, Helpdesk, Mails, Apps, Files, Sales & Marketing with [ZOHO](https://go.zoho.com/Jfo)
