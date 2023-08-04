#!/bin/bash

ACTION=$1

case $ACTION in
    start)
        echo -e "\e[32m Starting payement service \e[0m"
        exit 0
        ;;
    stop)
        echo -e "\e[33m Stopping payment service \e[0m"
        exit 1
        ;;
    restart)
        echo -e "\e[34m Restarting Payment service \e[0m"
        exit 2
        ;;
    *)
        echo -e "\e[35m Valid Options are start or stop or restart \e[0m"
        echo -e "\e[33m Example Usage \e[0m :\n \t bash scriptName stop"
        exit 3
        ;; 
esac