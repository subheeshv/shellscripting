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

echo -n "Downloading the ${COMPONENT} component:"
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" 
stat $? 


echo -n "Clean up of ${COMPONENT} : "
cd /usr/share/nginx/html    
rm -rf *     &>>  ${LOGFILE}
stat $?

echo -n "Extracting ${COMPONENT} :"
unzip /tmp/frontend.zip     &>>  /tmp/frontend.log
stat $?

echo -n "Sorting the ${COMPONENT} files :"
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md  &>>  ${LOGFILE}
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $? 


echo -n "Restarting ${COMPONENT}:"
systemctl daemon-reload     &>>  ${LOGFILE}
systemctl restart nginx     &>>  ${LOGFILE}
stat $?

echo -e "\e[35m ${COMPONENT} Installation Is Completed \e[0m \n"