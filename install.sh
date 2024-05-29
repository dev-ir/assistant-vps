#!/bin/bash

red='\033[0;31m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

wellcome(){
    echo -e "Hi , welcome to dev-ir script"
    echo -e "1- install speedtest on IR VPS"
}

wellcome
