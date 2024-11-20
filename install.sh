#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m'

# [[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

loader(){
    install_jq
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    # Fetch server isp using ip-api.com
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
}

install_speedtest(){
    sudo apt-get update && sudo apt-get install
    wget "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz"
    tar -zxvf ookla-speedtest-1.2.0-linux-x86_64.tgz
    cp speedtest /usr/bin
    sleep .5
    speedtest
}

change_ssh_port(){
    echo ""
    echo -n "Please enter the port you would like SSH to run on > "
    while read SSHPORT; do
        if [[ "$SSHPORT" =~ ^[0-9]{2,5}$ || "$SSHPORT" = 22 ]]; then
            if [[ "$SSHPORT" -ge 1024 && "$SSHPORT" -le 65535 || "$SSHPORT" = 22 ]]; then
                # Create backup of current SSH config
                NOW=$(date +"%m_%d_%Y-%H_%M_%S")
                cp /etc/ssh/sshd_config /etc/ssh/sshd_config.inst.bckup.$NOW
                # Apply changes to sshd_config
                sed -i -e "/Port /c\Port $SSHPORT" /etc/ssh/sshd_config
                echo -e "Restarting SSH in 5 seconds. Please wait.\n"
                sleep 5
                # Restart SSH service
                service sshd restart
                echo ""
                echo -e "The SSH port has been changed to $SSHPORT. Please login using that port to test BEFORE ending this session.\n"
                exit 0
            else
                echo -e "Invalid port: must be 22, or between 1024 and 65535."
                echo -n "Please enter the port you would like SSH to run on > "
            fi
        else
            echo -e "Invalid port: must be numeric!"
            echo -n "Please enter the port you would like SSH to run on > "
        fi
    done
    
    echo ""
}
setupFakeWebSite(){
    sudo apt-get update
    sudo apt-get install unzip -y
    
    if ! command -v nginx &> /dev/null; then
        echo "The Nginx software is not installed; the installation process has started."
        if sudo apt-get install -y nginx; then
            echo "Nginx was successfully installed."
        else
            echo "An error occurred during the Nginx installation process." >&2
            exit 1
        fi
    else
        echo "The Nginx software was already installed."
    fi
    
    cd /root || { echo "Failed to change directory to /root"; exit 1; }
    
    if [[ -d "website-templates-master" ]]; then
        echo "Removing existing 'website-templates-master' directory..."
        rm -rf website-templates-master
    fi
    
    wget https://github.com/learning-zone/website-templates/archive/refs/heads/master.zip
    unzip master.zip
    rm master.zip
    cd website-templates-master || { echo "Failed to change directory to randomfakehtml-master"; exit 1; }
    rm -rf assets
    rm ".gitattributes" "README.md" "_config.yml"
    
    randomTemplate=$(a=(*); echo ${a[$((RANDOM % ${#a[@]}))]} 2>&1)
    if [[ -n "$randomTemplate" ]]; then
        echo "Random template name: ${randomTemplate}"
    else
        echo "No directories found to choose from."
        exit 1
    fi
    
    if [[ -d "${randomTemplate}" && -d "/var/www/html/" ]]; then
        sudo rm -rf /var/www/html/*
        sudo cp -a "${randomTemplate}/." /var/www/html/
        echo "Template extracted successfully!"
    else
        echo "Extraction error!"
    fi
}


menu(){
    
    clear
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo "|   ##     ####    ####    ####   ####   ######    ##     ##  ##   ######        ##  ##   #####    ####        |"
    echo "|  ####   ##  ##  ##  ##    ##   ##  ##    ##     ####    ### ##     ##          ##  ##   ##  ##  ##  ##       |"
    echo "| ##  ##  ##      ##        ##   ##        ##    ##  ##   ######     ##          ##  ##   ##  ##  ##           |"
    echo "| ######   ####    ####     ##    ####     ##    ######   ######     ##   #####  ##  ##   #####    ####        |"
    echo "| ##  ##      ##      ##    ##       ##    ##    ##  ##   ## ###     ##          ##  ##   ##          ##       |"
    echo "| ##  ##  ##  ##  ##  ##    ##   ##  ##    ##    ##  ##   ##  ##     ##           ####    ##      ##  ## (2.5) |"
    echo "| ##  ##   ####    ####    ####   ####     ##    ##  ##   ##  ##     ##            ##     ##       ####        |"
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "|  Telegram Channel : ${YELLOW}@DVHOST_CLOUD ${NC} |  YouTube : ${RED}youtube.com/@dvhost_cloud${NC}   |  Version : ${GREEN} 2.5${NC} "
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "${GREEN}|Server Location:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}|Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}|Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------------------------------------------------------+"
    echo -e "${YELLOW}"
    echo -e "  ------- ${GREEN}Tools${YELLOW} ------- "
    echo "|"
    echo -e "|  1  - SpeedTest ookla"
    echo -e "|  2  - Speedtest bench.io"
    echo -e "|  3  - Speedtest ArvanCloud"
    echo -e "|  4  - System Monitors"
    echo "|"
    echo -e "  ------- ${GREEN}DNS Management${YELLOW} ------- "
    echo "|"
    echo -e "|  5  - Set DNS Shecan"
    echo -e "|  6  - Set DNS Google"
    echo "|"
    echo -e "  ------- ${GREEN}VPN Panels${YELLOW} ------- "
    echo "|"
    echo -e "|  7  - Install X-UI Panels"
    echo -e "|  8  - Install Marzban Panel"
    echo -e "|  9  - Auto SSL Marzban/X-UI (by @ErfJab)"
    echo -e "|  10 - Auto Backup Marzban/X-UI (by @AC_Lover)"
    echo -e "|  11 - Make Telegram Proxy (MTProto)"
    echo "|"
    
    echo -e "  ------- ${GREEN}Networking${YELLOW} ------- "
    echo "|"
    echo -e "|  12 - Disable IPv6"
    echo -e "|  13 - Disable/Enable Ping Response"
    echo -e "|  14 - Change source list IRAN"
    echo "|"
    echo -e " ------- ${GREEN}System Management${YELLOW} ------- "
    echo "|"
    echo -e "|  15 - Fix WhatsApp datetime"
    echo -e "|  16 - Remove IPtables Rules"
    echo -e "|  17 - Change SSH port"
    echo -e "|  18 - Change Password SSH"
    echo -e "|  19 - Update server and install dependences"
    echo "|"
    echo -e "  ------- ${GREEN}Optimizations${YELLOW} ------- "
    echo "|"
    echo -e "|  20 - Install BBR v3"
    echo -e "|  21 - Install WARP+"
    echo "|"
    echo -e "  ------- ${GREEN}Web Server${YELLOW} ------- "
    echo "|"
    echo -e "|  22 - Install Nginx + Fake-WebSite Template [HTML]"
    echo "|"
    echo -e " ------- ${GREEN}Exit${YELLOW} ------- "
    echo "|"
    echo -e "|  0  - Exit"
    echo ""
    echo -e "${NC}+-------------------------------------------------------------------------------------------------------------+${NC}"
    
    read -p "Please choose an option: " choice
    
    case $choice in
        1) install_speedtest ;;
        2) wget -qO- bench.sh | bash ;;
        3) bash <(curl -s https://raw.githubusercontent.com/arvancloud/support/main/bench.sh);;
        4) sudo apt-get install snapd && sudo snap install btop ;;
        5)
            cp /etc/resolv.conf /etc/resolv-backup.conf
            rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 178.22.122.100' >> /etc/resolv.conf && echo 'nameserver 185.51.200.2' >> /etc/resolv.conf
            echo "Shecan DNS Set."
        ;;
        6)
            cp /etc/resolv.conf /etc/resolv-backup.conf
            rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && echo 'nameserver 1.1.1.1' >> /etc/resolv.conf
            echo "Google DNS Set."
        ;;
        7)
            rm x-ui_installer.sh
            wget https://gist.githubusercontent.com/dev-ir/aef266871ca3945a662bd92bbf49b3ae/raw/d7b9ba940ac338c0e5816a84062de343c3eab742/x-ui_installer.sh
            bash x-ui_installer.sh
        ;;
        8)
            sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
            marzban cli admin create --sudo
        ;;
        9) sudo bash -c "$(curl -sL https://github.com/erfjab/ESSL/raw/main/essl.sh)";;
        10) bash <(curl -Ls https://github.com/AC-Lover/backup/raw/main/backup.sh) ;;
        
        11)
            echo "Please enter the following information:"
            read -p "Port number (default is 443): " port
            echo "for secret you you can use http://seriyps.ru/mtpgen.html "
            read -p "Secret key (should be a string of 32 hexadecimal characters): " secret_key
            echo "to get the server tag you should use telegram bot https://t.me/MTProxybot "
            read -p "Server tag (should be a string of 32 hexadecimal characters): " server_tag
            read -p "List of authentication methods - place empty for default - (should be a comma-separated list): " auth_methods
            read -p "MTProto domain (should be a valid domain name): " mtproto_domain
            port=${port:-443}
            auth_methods=${auth_methods:-"dd,-a tls"}
            curl -L -o mtp_install.sh https://git.io/fj5ru && \
            bash mtp_install.sh -p $port -s $secret_key -t $server_tag -a $auth_methods -d $mtproto_domain
            echo -e "Press ${RED}ENTER${NC} to continue"
            read -s -n 1
        ;;
        
        12)
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
            
            echo "IPv6 has been disabled"
        ;;
        
        13) bash <(curl -Ls https://gist.githubusercontent.com/dev-ir/4ec5873cbff302d3b1e0d9e85a6e95c5/raw/282f8c89fcd259b3adb88f089c3a833c32e66932/icmp-manager.sh) ;;
        
        14)
            if ! command -v python3 &> /dev/null
            then
                echo "Python 3 not installed."
                sudo apt update
                sudo apt install -y python3
            fi
            wget https://raw.githubusercontent.com/dev-ir/assistant-vps/master/core/change-name-server.py
            python3 change-name-server.py
        ;;
        15)
            sudo timedatectl set-timezone Asia/Tehran
            echo "Time & Date Updated."
        ;;
        16)
            
            iptables -F
            iptables -X
            iptables -P INPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -P OUTPUT ACCEPT
            
            echo "Rules iptable Removed."
        ;;
        17) change_ssh_port ;;
        18) sudo passwd ;;
        19)
            tput setaf 4
            echo "🟦 Updating the server..."
            apt update
            while [ $(pgrep apt-get) -gt 0 ]; do
                sleep 1
            done
            
            echo "🟦 Upgrading all packages..."
            apt upgrade -y
            
            apt install zenity tput
            clear
            
            packages=$(dpkg -l | grep "^i ." | awk '{print $2}')
            
            tput setaf 2
            
            echo "🟦 Packages to install:"
            echo
            for package in $packages; do
                echo "   $package"
            done
            
            tput setaf 4
            
            echo "🟦 Installing packages..."
            
            for package in $packages; do
                apt install -y $package
            done
            
            tput setaf 2
            
            echo "🟩 Server update completed."
            
            echo "🟦 Returning to main menu..."
            
            clear
        ;;
        
        20) curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh && chmod +x ./install_kernel.sh && ./install_kernel.sh ;;
        21) wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh ;;
        22)
            setupFakeWebSite
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
    
}

loader
menu
