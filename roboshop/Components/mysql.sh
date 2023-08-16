#!/bin/bash

COMPONENT=mysql

source Components/common.sh

echo -e "\e[35m Configuring ${COMPONENT} ...... \e[0m"

echo -n "Configuring ${COMPONENT} repo : "
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "Installing ${COMPONENT} : "
yum install mysql-community-server -y &>> ${LOGFILE}
stat $?

echo -n "Starting ${COMPONENT} : "
systemctl enable mysqld &>> ${LOGFILE}
systemctl start mysqld &>> ${LOGFILE}
stat $?

echo -n "Extracting default ${COMPONENT} root password : "
DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk -F " " '{print $NF}')
stat $?

echo "show databases;" | mysql -uroot -pRoboShop@1 &>> ${LOGFILE}
if [ $? -ne 0 ] ; then
    echo -n "performing root password reset : "
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1'" | mysql --connect-expired-password  -uroot -p$DEFAULT_ROOT_PASSWORD &>> ${LOGFILE}
    stat $?
fi

echo "show plugins;" | mysql -uroot -pRoboShop@1 | grep validate_password  &>>  ${LOGFILE}
if [ $? -eq 0 ]; then 
    echo -n "Uninstalling Password-validate plugin :"
    echo "uninstall plugin validate_password" | mysql -uroot -pRoboShop@1 &>>  ${LOGFILE}
    stat $?
fi 

echo -n "Downloading the $COMPONENT schema : "
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $? 

echo -n "Extracting the ${COMPONENT} schema : "
cd /tmp
unzip -o /tmp/${COMPONENT}.zip &>> ${LOGFILE}
stat $?

echo -n "Injecting the ${COMPONENT} scheme : "
cd ${COMPONENT}-main
mysql -u root  -pRoboShop@1 <shipping.sql &>> ${LOGFILE}
stat $?

echo -e "\e[35m ${COMPONENT} Installation Is Completed \e[0m \n"
