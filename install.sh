#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color

cur_dir=$(pwd)
پ
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1


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

    echo -e "${RED}+-----------------------------------------------------------------------------------------+${RED}"
    echo -e "${BLUE}|ver 0.0.1                                                                                |${RED}"
    echo -e "${BLUE}|  .+++=.   -+++=.     :=++++=.      :=+++*+-    .=+++++++++=  .=+++-  .=++-     :+++.    |${RED}" 
    echo -e "${BLUE}|   :@@.     -@@     :%#:    +@#.   =@=    *@#     @@=    .%%    @@+     @@@+     -@:     |${RED}" 
    echo -e "${BLUE}|   .@@      :@@    :@@       *@#          -@%     @@=      .    %@+     @++@#.   -@.     |${RED}" 
    echo -e "${BLUE}|   .@@      :@@    *@*       :@@.       .=%*      @@=   +*      %@+     @+ =@@:  -@:     |${RED}" 
    echo -e "${BLUE}|   .@@++++++*@@    %@+       .@@:    .+*%@*-      @@#++*@#      %@+     @+  -@@- -@:     |${RED}" 
    echo -e "${BLUE}|   .@@      -@@    #@#       :@@.         +@%     @@=   :-      %@+     @+   .%@+:@:     |${RED}" 
    echo -e "${BLUE}|   .@@      :@@    -@@.      +@*           @@:    @@=     :=    %@+     @+     *@#@:     |${RED}" 
    echo -e "${BLUE}|   :@@.     -@@     -@%-   .+@+    *@-    +@+     @@=    .%%    @@+     @*      +@@:     |${RED}" 
    echo -e "${BLUE}|  .=++=.   -+++=.     :=+++=-      .-=++++-.    .=+++++++++=  .=+++-  .=++-      -+.     |${RED}"
    echo -e "${BLUE}|                                                                                         |${RED}"
    echo -e "${BLUE}+-----------------------------------------------------------------------------------------+${RED}"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo -e "${GREEN}+-----------------------------------------------------------------------------------------+${NC}"
    echo -e "$YELLOW${BLUE}|"
    echo -e "${BLUE}| 1  - Install Speedtest.net ( IRAN )"
    echo -e "${BLUE}| 2  - Install Monitoring    ( IRAN )"
    echo -e "${BLUE}| 3  - Install X-UI          ( Alireza , Sanaei )"
    echo -e "${BLUE}| 4  - Set DNS Google        ( IRAN )"
    echo -e "${BLUE}| 5  - Set DNS Shecan        ( IRAN )"
    echo -e "${BLUE}| 6  - FIX Time WhatsApp     ( Kharej )"
    echo -e "${BLUE}| 7  - Disable IPv6          ( Any )"
    echo -e "${BLUE}| 8  - Speedtest bench       ( Any )"
    echo -e "${BLUE}| 9  - Remove Iptables       ( Any )"
    echo -e "${BLUE}| 10 - Install BBR v3        ( IRAN )"
    echo -e "${BLUE}| 11 - Install WARP+         ( Kharej )"
    echo -e "${BLUE}| 12 - Speedtest ArvanCloud  ( Kharej )"
    echo -e "${BLUE}| 13 - Change SSH port       ( Any )"
    echo -e "${BLUE}| 0  - Exit"
    echo -e "${BLUE}|"
    echo -e "${GREEN}+-----------------------------------------------------------------------------------------+"

    read -p "Enter option number: " choice

    case $choice in
    1)
        install_speedtest
        echo "All Package is Upadted."
        ;;
    2)
        # htop
        sudo apt install btop
        btop
        ;;
    3)
        # htop
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

    12)
        bash <(curl -s https://raw.githubusercontent.com/arvancloud/support/main/bench.sh)
        ;;

    13)
        change_ssh_port
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

wellcome
