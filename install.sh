#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

cur_dir=$(pwd)



wellcome(){
    echo -e "Hi , welcome to dev-ir script"
    echo -e "1- install speedtest on IR VPS"
}

wellcome