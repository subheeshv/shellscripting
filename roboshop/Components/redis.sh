#!/bin/bash

USER_ID=$(id -u)
COMPONENT=redis
LOGFILE=/tmp/${COMPONENT}.log

if [ $USER_ID -ne 0] ; then
    echo -e "\e[31m Script is executed with the root user or sudo previlege \e[0m \n\t example \n\t\t sudo bash wrapper.sh frontend"
    exit 1
fi

stat() {
    if [ $1 -eq 0] ; then
        echo -e "\e[32m success \e[0m"
    else
        echo -e "\e[31m failure \e[0m"
        exit 2
    fi
}

echo -e "\e[35m Configuring ${COMPONENT} ....... \e[0m"

echo -n "Configuring ${COMPONENT} repo : "
curl -L https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/redis.repo -o /etc/yum.repos.d/${COMPONENT}.repo &>> ${LOGFILE} 
stat $? 

echo -n "Installing ${COMPONENT} : "
yum install redis-6.2.12 -y  &>> ${LOGFILE}
stat $?

echo -n "Enabling ${COMPONENT} visibility : "
sed -ie 's\127.0.0.1\0.0.0.0/g' /etc/${COMPONENT}.conf
sed -ie 's\127.0.0.1\0.0.0.0/g' /etc/${COMPONENT}/${COMPONENT}.conf
stat $?

echo -n "Starting the ${COMPONENT} : "
systemctl daemon-reload &>> ${LOGFILE}
systemctl enable ${COMPONENT} &>> ${LOGFILE}
systemctl start ${COMPONENT} &>> ${LOGFILE}
stat $?

echo -e "\e[35m Installation of ${COMPONENT} completed \e[0m"


