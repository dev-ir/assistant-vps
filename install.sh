#!/bin/bash

#add color for text
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset color

#values
tVersion="(2.5.1)"
tGoogle="${BLUE}G${NC}${RED}o${NC}${YELLOW}o${NC}${BLUE}o${NC}${GREEN}l${NC}${RED}e${NC}${YELLOW}"

cur_dir=$(pwd)
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

display_header (){
    # clear
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo "|   ##     ####    ####    ####   ####   ######    ##     ##  ##   ######        ##  ##   #####    ####        |"
    echo "|  ####   ##  ##  ##  ##    ##   ##  ##    ##     ####    ### ##     ##          ##  ##   ##  ##  ##  ##       |" 
    echo "| ##  ##  ##      ##        ##   ##        ##    ##  ##   ######     ##          ##  ##   ##  ##  ##           |" 
    echo "| ######   ####    ####     ##    ####     ##    ######   ######     ##   #####  ##  ##   #####    ####        |" 
    echo "| ##  ##      ##      ##    ##       ##    ##    ##  ##   ## ###     ##          ##  ##   ##          ##       |" 
    echo "| ##  ##  ##  ##  ##  ##    ##   ##  ##    ##    ##  ##   ##  ##     ##           ####    ##      ##  ##       |" 
    echo -e "| ##  ##   ####    ####    ####   ####     ##    ##  ##   ##  ##     ##            ##     ##       #### ${tVersion}|"
    echo -e "| ${YELLOW}Assistant-VPS${NC} / try to Save your Machine                                   ${GREEN}TG CHANNEL${NC} : @DVHOST_CLOUD        |"
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "${GREEN}|Server Location:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}|Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}|Server ISP:${NC} $SERVER_ISP"
}

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
    while  true; do
        wellcome
    done
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
    cd website-templates-master || { echo "Failed to change directory to website-templates-master"; exit 1; }
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

install_speedtest(){
    echo "Installing Speedtest CLI from Ookla..."
    sudo apt-get update && sudo apt-get install -y wget
    wget "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz"
    if [ $? -ne 0 ]; then
        echo "Download failed. We will try using another method..."
        install_speedtest_cli
        return
    fi
    tar -zxvf ookla-speedtest-1.2.0-linux-x86_64.tgz
    sudo cp speedtest /usr/bin
    sleep 0.5
    speedtest
}

install_speedtest_cli(){
    echo "Installing speedtest-cli using the official package..."
    sudo apt-get update
    sudo apt-get install -y speedtest-cli
    if [ $? -eq 0 ]; then
        echo "Installation was successful. Running speedtest..."
        speedtest
    else
        echo "Installation of speedtest-cli failed."
    fi
}

SUBMENU_SpeedTestServices() {
    while true; do
        display_header
        echo "+--------------------------------------------------------------------------------------------------------------+"
        echo -e "${GREEN}├──${NC}${RED}[ Main Menu 」${NC}/ ${NC}${RED}[ SpeedTestꜝ Services ˩${NC}"
        echo -e "${GREEN}|Please choose an option:${NC}"
        echo "+--------------------------------------------------------------------------------------------------------------+"
        echo -e "${BLUE}|"
        echo -e "${BLUE}| 1 - Analyser Speedtester [bench.io]"
        echo -e "${BLUE}| 2 - Install Speedtester [by Ookla]"
        echo -e "${BLUE}| 3 - Install Speedtester [by ArvanCloud]"
        echo -e "${BLUE}| 4 - The download Speed for a ${NC}${RED}「 1GB」${NC}${BLUE}${NC}${YELLOW}File [srv-Global]"
        echo -e "${BLUE}| 5 - The download Speed for a ${NC}${RED}「10GB」${NC}${BLUE}${NC}${YELLOW}File [srv-fast.com]"
        echo -e "${BLUE}| 6 - Block all SpeedTester WebSites"
        echo -e "${BLUE}| q - Return to Main Menu"
        echo -e "${BLUE}|"
        echo -e "${NC}+---------------------------------------------------------------------------------------------------------------+"
        read -p "Please select an option: " Chosen

        case $Chosen in
            1)
                wget -qO- bench.sh | bash
                ;;
            2)
                if ! command -v speedtest &> /dev/null
                then
                    echo "Speedtest is not installed. Installing now..."
                    install_speedtest
                else
                    echo "Speedtest is already installed. Running speedtest..."
                    speedtest
                fi
                ;;
            3)
                bash <(curl -s https://raw.githubusercontent.com/arvancloud/support/main/bench.sh)
                ;;
            4)
                URL="http://speedtest.tele2.net/1GB.zip"
                echo "Downloading a file from $URL for speed testing..."
                output=$(wget -O /dev/null $URL 2>&1)
                speed=$(echo "$output" | grep -oP '(?<=\()\d+(\.\d+)? [KM]B/s(?=\))')
                time_taken=$(echo "$output" | grep -oP '\d+m\d+\.\d+s')
                minutes=$(echo "$time_taken" | grep -oP '\d+(?=m)')
                seconds=$(echo "$time_taken" | grep -oP '\d+\.\d+(?=s)')
                total_seconds=$(echo "$((minutes * 60 + seconds))")
                echo "Download completed."
                echo "Speed: $speed"
                echo "Time taken: $time_taken (Total seconds: $total_seconds)"
                ;;
            5)
                if ! command -v lftp &> /dev/null; then
                    echo "'lftp' is being installed..."
                    sudo apt-get update
                    sudo apt-get install -y lftp
                fi
                output=$(lftp -e "pget -n 5 -c https://fastly.akamai.net/10GB.zip; exit" -o /dev/null 2>&1)
                speed=$(echo "$output" | grep -oP '\d+(\.\d+)? [KM]B/s' | tail -n 1)
                time_taken=$(echo "$output" | grep -oP '\d+m\d+\.\d+s' | tail -n 1)
                if [[ $time_taken ]]; then
                    minutes=$(echo "$time_taken" | grep -oP '\d+(?=m)')
                    seconds=$(echo "$time_taken" | grep -oP '\d+\.\d+(?=s)')
                    total_seconds=$(echo "$((minutes * 60 + seconds))")
                else
                    total_seconds=0
                fi
                echo "Download completed."
                echo "Speed: $speed"
                echo "Time taken: $time_taken (Total seconds: $total_seconds)"
                ;;
            6)
                bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/speedtest-ban/master/main.sh)
                ;;
            q|0)
                break 
                ;;
            *)
                echo -e "— ${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        echo -e "\n"
        read -p "Press Enter to continue..."
    done
}

wellcome(){
    echo -e "\n\n"
    display_header

    echo "+---------------------------------------------------------------------------------------------------------------+"
    echo -e "${GREEN}├──${NC}${RED}[ Main Menu 」${NC}"
    echo -e "${GREEN}|Please choose an option:${NC}"
    echo "+---------------------------------------------------------------------------------------------------------------+"
    echo -e "${BLUE}|"
    echo -e "${BLUE}| 01 - Install ${NC}${RED}*${NC}Monitoring"
    echo -e "${BLUE}| 02 - Install X-UI Panel                       ( Alireza , Sanaei , Vaxilu , FranzKafkaYu )"
    echo -e "${BLUE}| 03 - Set DNS ${tGoogle}"
    echo -e "${BLUE}| 04 - Set DNS Shecan"
    echo -e "${BLUE}| 05 - 「Fix 」 ${NC}${GREEN}WhatsApp${NC}${BLUE} DateTime"
    echo -e "${BLUE}| 06 - Disable IPv6"
    echo -e "${BLUE}| 07 ┬ SpeedTestꜝ Services"
    echo -e "${BLUE}|    └─ Analyser Speedtester [bench.io]"
    echo -e "${BLUE}|    └─ Install Speedtester [by Ookla]"
    echo -e "${BLUE}|    └─ Install Speedtester [by ArvanCloud]"
    echo -e "${BLUE}|    └─ Test Download speed by Downloading a File."
    echo -e "${BLUE}|    └─ Block all SpeedTester WebSites"
    echo -e "${BLUE}| 08 - Remove IPtables Rules"
    echo -e "${BLUE}| 09 - Install BBR v3"
    echo -e "${BLUE}| 10 - Install WARP+"
    echo -e "${BLUE}| 11 - Change SSH port"
    echo -e "${BLUE}| 12 - Auto SSL Marzban/X-UI (by @ErfJab)"
    echo -e "${BLUE}| 13 - Auto Backup Marzban/X-UI (by @AC_Lover)"
    echo -e "${BLUE}| 14 - Change Password SSH"
    echo -e "${BLUE}| 15 - Make Telegram Proxy (MTProto)"
    echo -e "${BLUE}| 16 - Update server and install dependences"
    echo -e "${BLUE}| 17 - Change the Source repository list to IRAN."
    echo -e "${BLUE}| 18 - Install Marzban Panel"
    echo -e "${BLUE}| 19 - Disable/Enable Ping Response"
    echo -e "${BLUE}| 20 - List Port Usage"
    echo -e "${BLUE}| 21 - Install Nginx + Fake-WebSite Template [HTML]"
    echo -e "${BLUE}|  q - Exit"
    echo -e "${BLUE}|"
    echo -e "${NC}+---------------------------------------------------------------------------------------------------------------+"

    read -p "Enter option number: " choice

    case $choice in
    1)
        # htop
        # sudo apt install btop -y
        # btop
        # install from snap
        sudo apt-get install snapd
        sudo snap install btop
        ;;
    2)
        if [ -f "x-ui_installer.sh" ]; then
            rm x-ui_installer.sh
        fi
        wget https://gist.githubusercontent.com/dev-ir/aef266871ca3945a662bd92bbf49b3ae/raw/d7b9ba940ac338c0e5816a84062de343c3eab742/x-ui_installer.sh
        bash x-ui_installer.sh
        ;;
    3)
        cp /etc/resolv.conf /etc/resolv-backup.conf 
        rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && echo 'nameserver 1.1.1.1' >> /etc/resolv.conf
        echo -e "${tGoogle} DNS Set.${NC}"
        
        ;;
    4)
        cp /etc/resolv.conf /etc/resolv-backup.conf 
        rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 178.22.122.100' >> /etc/resolv.conf && echo 'nameserver 185.51.200.2' >> /etc/resolv.conf
        echo "Shecan DNS Set."
        ;;
    5)
        sudo timedatectl set-timezone Asia/Tehran
        # sudo timedatectl set-timezone UTC
        echo -e "\n— ${GREEN}Time & Date Updated.${NC}"
        echo -e "— The server needs to be ${BLUE}rebooted${NC} to ${GREEN}apply the changes.${NC}"
        echo -ne "\nDo you want to ${RED}reboot${NC} the system now? (y/n):"
        read -r reboot_choice
        if [ "$reboot_choice" = "y" ]; then
            echo "${GREEN}Rebooting${NC} system..."
            sudo reboot
        else
            echo -e "You chose not to reboot the system. Please ${RED}REBOOT${NC} manually later."
        fi
        ;;
    6)
        echo -e "${RED}"
        sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
        echo " "
        echo -e "${NC}${GREEN}IPv6${NC} has been ${RED}DISABLED${NC}"
        ;;
    7)
        SUBMENU_SpeedTestServices
        ;;
    8)
        echo -e "${RED}"
        iptables -F
        iptables -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        echo " "
        echo -e "${NC}Rules iptable ${RED}Removed${NC}."
        ;;
    9)
        curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh && chmod +x ./install_kernel.sh && ./install_kernel.sh
        ;;
    10)
        wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
        ;;
    11)
        change_ssh_port
        ;;
    12)
        sudo bash -c "$(curl -sL https://github.com/erfjab/ESSL/raw/main/essl.sh)"
        ;;
    13)
        bash <(curl -Ls https://github.com/AC-Lover/backup/raw/main/backup.sh)
        ;;
    14)
        sudo passwd
        ;;
    15)
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
    16)
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
    17)
        if ! command -v python3 &> /dev/null
        then
            echo "Python 3 not installed."
            sudo apt update
            sudo apt install -y python3
        fi
        wget https://raw.githubusercontent.com/dev-ir/assistant-vps/master/core/change-name-server.py
        python3 change-name-server.py
        ;;
    18)
        sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
        marzban cli admin create --sudo
        ;;
    19)
        wget https://gist.githubusercontent.com/dev-ir/4ec5873cbff302d3b1e0d9e85a6e95c5/raw/282f8c89fcd259b3adb88f089c3a833c32e66932/icmp-manager.sh
        bash icmp-manager.sh
        ;;
    20)
        bash <(curl -Ls https://gist.githubusercontent.com/dev-ir/9e0d30603a7f9c50700c1d48a206af4d/raw/786d93cbdd79315c9acbc13cd47aa1523f33e944/list-port-usages)
        ;;
    21)
        setupFakeWebSite
        ;;
    q|0)
        echo -e "${GREEN}Exiting program...${NC}"
        exit 0 
        ;;
    *)
        echo -e "— ${RED}Invalid option. Please try again.${NC}"
        ;;
    esac
    echo -e "\n"
    read -p "Press Enter to continue..."
}


loader
