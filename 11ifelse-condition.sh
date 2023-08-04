#!/bin/bash

ACTION=$1

if [ "$ACTION" == "start" ];then
    echo -e "\e[31m starting payment service \e[0m"
    exit 0

elif [ "$ACTION" == "stop" ];then
    echo -e "\e[32m stopping payment service \e[0m"
    exit 1

elif [ "$ACTION" == "restart" ];then
    echo -e "\e[33m restarting payment service \e[0m"
    exit 2

else
    echo -e "\e[34m valid options are start and stop and restart \e[0m"
    echo -e "\e[35m example usage \t bash scriptname stop \e[0m"
    exit 3

fi