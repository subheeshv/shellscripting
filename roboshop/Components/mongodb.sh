#!/bin/bash

USER_ID=$(id -u)
COMPONENT=mongodb
LOGFILE="/tmp/${COMPONENT}.log"

if [ $USER_ID -ne 0 ] ; then
    echo -e "e[31m Script is expected to executed by the root user or with a sudo privilege \e[0m \n \t Example: \n\t\t sudo bash wrapper.sh frontend"
    exit 1
fi

stat() {
    if [ $1 -eq 0 ] ; then
        echo -e "\e[32m success \e[0m"
    else
        echo -e "\e[31m failure \e[0m"
    exit 2
    fi
}

echo -e "\e[35m Configuring ${COMPONENT} ......! \e[0m \n"

echo -n "Configuring ${COMPONENT} repo :"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/stans-robot-project/mongodb/main/mongo.repo 
stat $? 

echo -n "installing ${COMPONENT} :"
yum install mongodb-org -y &>> ${LOGFILE}
stat $?

echo -n "configuring ${COMPONENT}visibility :"
sed -ie 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
stat $?

echo -n "starting ${COMPONENT} : "
systemctl enable mongod &>> ${LOGFILE}
systemctl restart mongod &>> ${LOGFILE}
stat $?

echo -n "Downloading the ${COMPONENT} schema: "
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" 
stat $?

echo -n "extrating the ${COMPONENT} scheme: "
cd /tmp
unzip -o ${COMPONENT}.zip &>> ${LOGFILE}
stat $?

echo -n "injecting ${COMPONENT} schema: "
cd ${COMPONENT}-main
mongo < catalogue.js &>> ${LOGFILE}
mongo < users.js &>> ${LOGFILE}
stat $?

cho -e "\e[35m ${COMPONENT} Installation Is Completed \e[0m \n"




