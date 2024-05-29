#!/bin/bash

#add color for text
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)


# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

wellcome(){
    echo -e "Hi , welcome to dev-ir script"
    echo -e "1- install speedtest on IR VPS"
    echo -e "${green}Please choose an option:${red}"

    read -p "Enter option number: " choice
}

wellcome
