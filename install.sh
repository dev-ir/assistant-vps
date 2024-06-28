#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color

cur_dir=$(pwd)
# check root
#[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1


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

    #install_jq

    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')

    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

    # Fetch server isp using ip-api.com 
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

    wellcome

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

wellcome(){

    clear
    echo "+----------------------------------------------------------------------------+"
    echo "|                   _       _                  _                              |"
    echo "|                  (_)     | |                | |                             |"
    echo "|   __ _  ___  ___  _  ___ | |_   __ _  _ __  | |_    __   __ _ __   ___      |"
    echo "|  / _  |/ __|/ __|| |/ __|| __| / _  ||  _ \ | __|   \ \ / /| '_ \ / __|     |"
    echo "|  | (_| |\__ \\__ \| |\__ \| |_ | (_| || | | || |_     \ V / | |_) |\__ \     |"
    echo "|  \____||___/|___/|_||___/ \__| \__,_||_| |_| \__|     \_/  | .__/ |___/     |"
    echo "|                                                            | |              |"
    echo "|                                                            |_|              |"
    echo "+----------------------------------------------------------------------------+"
    echo -e "${GREEN}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------+"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo "+---------------------------------------------------------------+"
    echo -e "$YELLOW|"
    echo -e "${BLUE}| 1  - Install Speedtest.net                    ( Any )"
    echo -e "${BLUE}| 2  - Install Monitoring                       ( IRAN )"
    echo -e "${BLUE}| 3  - Install X-UI Panel                       ( Alireza , Sanaei , Vaxilu , FranzKafkaYu )"
    echo -e "${BLUE}| 4  - Set DNS Google                           ( IRAN )"
    echo -e "${BLUE}| 5  - Set DNS Shecan                           ( IRAN )"
    echo -e "${BLUE}| 6  - FIX Time WhatsApp                        ( Kharej )"
    echo -e "${BLUE}| 7  - Disable IPv6                             ( Any )"
    echo -e "${BLUE}| 8  - Speedtest bench                          ( Any )"
    echo -e "${BLUE}| 9  - Remove Iptables                          ( Any )"
    echo -e "${BLUE}| 10 - Install BBR v3                           ( IRAN )"
    echo -e "${BLUE}| 11 - Install WARP+                            ( Kharej )"
    echo -e "${BLUE}| 12 - Speedtest ArvanCloud                     ( Kharej )"
    echo -e "${BLUE}| 13 - Change SSH port                          ( Any )"
    echo -e "${BLUE}| 14 - Auto SSL Marzban/X-UI (by @ErfJab)       ( Any )"
    echo -e "${BLUE}| 15 - Auto Backup Marzban/X-UI (by @AC_Lover)  ( Kharej )"
    echo -e "${BLUE}| 16 - Change Password SSH                      ( Any )"
    echo -e "${BLUE}| 17 - Make Telegram Proxy (MTProto)            ( Kharej )"
    echo -e "${BLUE}| 18 - Update server and install dependences    ( Any )"
    echo -e "${BLUE}| 19 - Change source list IRAN                  ( IRAN )"
    echo -e "${BLUE}| 20 - Install Marzban Panel                    ( IRAN )"
    echo -e "${BLUE}| 21 - Disable/Enable Ping Response             ( Any )"
    echo -e "${BLUE}| 0  - Exit"
    echo -e "${BLUE}|"
    echo -e "${GREEN}+---------------------------------------------------------------------------+"

    read -p "Enter option number: " choice

    case $choice in
    1)
        install_speedtest
        ;;
    2)
        # htop
        sudo apt install btop -y
        btop
        ;;
    3)
        rm x-ui_installer.sh
        wget https://gist.githubusercontent.com/dev-ir/aef266871ca3945a662bd92bbf49b3ae/raw/d7b9ba940ac338c0e5816a84062de343c3eab742/x-ui_installer.sh
        bash x-ui_installer.sh
        ;;
    4)
        cp /etc/resolv.conf /etc/resolv-backup.conf 
        rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && echo 'nameserver 1.1.1.1' >> /etc/resolv.conf

        echo "Google DNS Set."

        ;;
    5)
        cp /etc/resolv.conf /etc/resolv-backup.conf 
        rm -rf /etc/resolv.conf && touch /etc/resolv.conf && echo 'nameserver 178.22.122.100' >> /etc/resolv.conf && echo 'nameserver 185.51.200.2' >> /etc/resolv.conf

        echo "Shecan DNS Set."

        ;;
    6)
        sudo timedatectl set-timezone Asia/Tehran
        # sudo timedatectl set-timezone UTC
        echo "Time & Date Updated."

        ;;
    7)
        sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
        
        echo "IPv6 has been disabled"
        ;;
    8)
        wget -qO- bench.sh | bash
        ;;
    9)
        iptables -F
        iptables -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT

        echo "Rules iptable Removed."
        ;;
    10)
        curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh && chmod +x ./install_kernel.sh && ./install_kernel.sh
        ;;

    11)
        wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
        ;;

    12)
        bash <(curl -s https://raw.githubusercontent.com/arvancloud/support/main/bench.sh)
        ;;

    13)
        change_ssh_port
        ;;

    14)
        sudo bash -c "$(curl -sL https://github.com/erfjab/ESSL/raw/main/essl.sh)"
        ;;
    15)
        bash <(curl -Ls https://github.com/AC-Lover/backup/raw/main/backup.sh)
        ;;
    16)
        sudo passwd
        ;;
    17)
            echo "Please enter the following information:"
            read -p "Port number (default is 443): " port
            echo "for secret you you can use http://seriyps.ru/mtpgen.html "
            read -p "Secret key (should be a string of 32 hexadecimal characters): " secret_key
            echo "to get the server tag you should use telegram bot https://t.me/MTProxybot "
            read -p "Server tag (should be a string of 32 hexadecimal characters): " server_tag
            read -p "List of authentication methods - place empty for default - (should be a comma-separated list): " auth_methods
            read -p "MTProto domain (should be a valid domain name): " mtproto_domain
            # Set default values if user input is empty
            port=${port:-443}
            auth_methods=${auth_methods:-"dd,-a tls"}
            # Download and run MTProto installation script
            curl -L -o mtp_install.sh https://git.io/fj5ru && \
            bash mtp_install.sh -p $port -s $secret_key -t $server_tag -a $auth_methods -d $mtproto_domain
            echo -e "Press ${RED}ENTER${NC} to continue"
            read -s -n 1
        ;;
    18)
            # Set a vibrant blue background color for the script's output
            tput setaf 4

            # Perform the server update process
            echo "🟦 Updating the server..."

            # Update the package repositories
            apt update 

            # Wait for the update process to complete
            while [ $(pgrep apt-get) -gt 0 ]; do
                sleep 1
            done

            # Upgrade all installed packages
            echo "🟦 Upgrading all packages..."
            apt upgrade -y

            apt install zenity tput
            # Clear the screen to show the updated package list
            clear

            # Check for any packages to install
            packages=$(dpkg -l | grep "^i ." | awk '{print $2}')

            # Set a contrasting yellow color for the packages list
            tput setaf 2

            # Display the list of packages to install
            echo "🟦 Packages to install:"
            echo
            for package in $packages; do
                echo "   $package"
            done

            # Set the background color back to blue
            tput setaf 4

            # Install the packages automatically
            echo "🟦 Installing packages..."

            for package in $packages; do
                apt install -y $package
            done

            # Set a green color to indicate successful completion
            tput setaf 2

            # Display completion message
            echo "🟩 Server update completed."

            # Return to the main menu
            echo "🟦 Returning to main menu..."

            # Clear the screen for a fresh start
            clear
        ;;

    19)
        # sudo passwd

            if ! command -v python3 &> /dev/null
            then
                echo "Python 3 نصب نیست. در حال نصب..."
                sudo apt update
                sudo apt install -y python3
            fi

            python3 core/change-name-server.py

        ;;

    20)
        sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
        marzban cli admin create --sudo
        ;;
    21)
        wget https://gist.githubusercontent.com/dev-ir/4ec5873cbff302d3b1e0d9e85a6e95c5/raw/282f8c89fcd259b3adb88f089c3a833c32e66932/icmp-manager.sh
        bash icmp-manager.sh

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