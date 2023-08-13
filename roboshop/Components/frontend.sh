#!/bin/bash

USER_ID=$(id -u)
COMPONENT=frontend
LOGFILE="/tmp/$COMPONENT.log"

if [ $USER_ID -ne 0 ];then
    echo -e "\e[31m Script is expected to execute with sudo user \e[0m \n \t example:sudo bash wrapper.sh frontend"
    exit 1
fi
stat() {
    if [ $1 -eq 0 ];then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m failure \e[0m"
        exit 2
    fi
}

echo -e "\e[35m Configuring ${COMPONENT}.....! \e[0m \n"

echo -n "installing ${COMPONENT} :"
yum install nginx -y &>> ${LOGFILE}
stat $?


echo -n "Starting Nginx:" 
systemctl enable nginx   &>>  ${LOGFILE}
systemctl start nginx    &>>  ${LOGFILE}
stat $?
