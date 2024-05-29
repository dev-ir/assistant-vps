#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)
پ
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

wellcome(){

    clear

    echo -e "${RED}+-----------------------------------------------------------------------------------------+${NC}"
    echo -e "${BLUE}|ver 0.0.1                                                                                |${NC}"
    echo -e "${BLUE}|  .+++=.   -+++=.     :=++++=.      :=+++*+-    .=+++++++++=  .=+++-  .=++-     :+++.    |${NC}" 
    echo -e "${BLUE}|   :@@.     -@@     :%#:    +@#.   =@=    *@#     @@=    .%%    @@+     @@@+     -@:     |${NC}" 
    echo -e "${BLUE}|   .@@      :@@    :@@       *@#          -@%     @@=      .    %@+     @++@#.   -@.     |${NC}" 
    echo -e "${BLUE}|   .@@      :@@    *@*       :@@.       .=%*      @@=   +*      %@+     @+ =@@:  -@:     |${NC}" 
    echo -e "${BLUE}|   .@@++++++*@@    %@+       .@@:    .+*%@*-      @@#++*@#      %@+     @+  -@@- -@:     |${NC}" 
    echo -e "${BLUE}|   .@@      -@@    #@#       :@@.         +@%     @@=   :-      %@+     @+   .%@+:@:     |${NC}" 
    echo -e "${BLUE}|   .@@      :@@    -@@.      +@*           @@:    @@=     :=    %@+     @+     *@#@:     |${NC}" 
    echo -e "${BLUE}|   :@@.     -@@     -@%-   .+@+    *@-    +@+     @@=    .%%    @@+     @*      +@@:     |${NC}" 
    echo -e "${BLUE}|  .=++=.   -+++=.     :=+++=-      .-=++++-.    .=+++++++++=  .=+++-  .=++-      -+.     |${NC}"
    echo -e "${BLUE}|                                                                                         |${NC}"
    echo -e "${BLUE}+-----------------------------------------------------------------------------------------+${NC}"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo -e "${GREEN}+-----------------------------------------------------------------------------------------+${NC}"
    echo -e "$YELLOW${BLUE}|"

    echo -e "${BLUE}| 1 - Install Speedtest     ( IRAN )"
    echo -e "${BLUE}| 2 - Install Monitoring    ( IRAN )"
    echo -e "${BLUE}| 3 - Install X-UI          ( Alireza , Sanaei )"
    echo -e "${BLUE}| 4 - DNS Changer           ( IRAN )"
    echo -e "${BLUE}| 5 - FIX Time WhatsApp     ( Kharej )"
    echo -e "${BLUE}| 6 - Disable IPv6          ( Any )"
    echo -e "${BLUE}| 7 - Speedtest By bench    ( Any )"
    echo -e "${BLUE}| 8 - Remove Iptables       ( Any )"
    echo -e "${BLUE}| 9 - Fix Download Github   ( IRAN )"
    echo -e "${BLUE}| 0 - Exit"

    echo -e "${BLUE}|"
    echo -e "${GREEN}+-----------------------------------------------------------------------------------------+${NC}"

    read -p "Enter option number: " choice

}

wellcome
