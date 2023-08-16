#!/bin/bash
LOGFILE="/tmp/${COMPONENT}.log"
APPUSER="roboshop"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ] ; then
    echo -e "\e[31m script will be executed with root user or sudo previlege \e[0m \n \t example sudo bash wrapper.sh frontend"
    exit 1
fi

stat () {
    if [ $1 -eq 0 ] ; then
        echo -e "\e[32m success \e[0m"
    else
        echo -e "\e[31m failure \e[0m"
    exit 2
    fi
}

CREATE_USER() {
    id ${APPUSER} &>>${LOGFILE}
    if [ $? -ne 0 ] ; then
    echo -n "Creating application user account:"
    useradd roboshop
    stat $?
    fi
}

DOWNLOAD_AND_EXTRACT() {
    echo -n "downloading the ${COMPONENT} :"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" 
    stat $?

    cd /home/${APPUSER}/
    rm -rf ${COMPONENT} &>> ${LOGFILE}
    unzip -o /tmp/${COMPONENT}.zip &>> ${LOGFILE}
    stat $?

    echo -n "Changing the ownership : "
    mv ${COMPONENT}-main ${COMPONENT}
    chown -R ${APPUSER}:${APPUSER} /home/${APPUSER}/${COMPONENT}/
    stat $?
}

CONGIF_SVC() {
    echo -n "Configuring ${COMPONENT} system file : "
    sed -i -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/'  -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' /home/$APPUSER/${COMPONENT}/systemd.service
    mv /home/$APPUSER/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service

    echo -n "starting ${COMPONENT} service : "
    systemctl daemon-reload &>> ${LOGFILE}
    systemctl enable ${component} &>> ${LOGFILE}
    systemctl restart ${COMPONENT} &>> ${LOGFILE}
    stat $?
}

NODE_JS() {
    echo -e "\e[35m configuring ${COMPONENT} .....\e[0m \n"

    echo -n "configuring ${COMPONENT} repo : "
    curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - &>> ${LOGFILE}
    stat $?

    echo -n "Installing nodejs : "
    yum install nodejs -y &>> ${LOGFILE}
    stat $?

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    echo -n "Generating the ${COMPONENT} artificats : "
    cd /home/${APPUSER}/${COMPONENT}/
    npm install &>> ${LOGFILE}
    stat $?

    CONGIF_SVC
}

MVN_PACKAGE() {
    echo -n "Generating ${COMPONENT} artifatcs : "
    cd /home/${APPUSER}/${COMPONENT}
    mvn clean package &>> ${LOGFILE}
    mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
    stat $?
}

JAVA() {
    echo -e "\e[35m Configuring ${COMPONENT} ..... \e[0m"

    echo -n "Installing ${COMPONENT} : "
    yum install maven -y &>> ${LOGFILE}
    stat $?

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    MVN_PACKAGE

    CONGIF_SVC
}
