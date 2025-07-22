#!/bin/bash

if [ $(id -u) -ne 0 ]; then 
    echo -e "You should perform this as root user"
    exit 1
fi 

LOG_FILE=/tmp/jinstall.log
Stat() {
    if [ $1 -ne 0 ]; then 
        echo "Installation Failed : Check log $LOG_FILE"
        exit 2 
    fi 
}

echo -e "\n--- Installing dependencies ---" | tee $LOG_FILE
yum install fontconfig java-11-openjdk-devel wget -y &>>$LOG_FILE
Stat $?

echo -e "\n--- Downloading Jenkins repo file ---" | tee -a $LOG_FILE
curl -L --insecure -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>>$LOG_FILE
Stat $?

echo -e "\n--- Importing Jenkins GPG key ---" | tee -a $LOG_FILE
curl -L --insecure https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key | rpm --import - &>>$LOG_FILE
Stat $?

echo -e "\n--- Installing Jenkins ---" | tee -a $LOG_FILE
yum install jenkins --nogpgcheck -y &>>$LOG_FILE
Stat $?

echo -e "\n--- Enabling and Starting Jenkins ---" | tee -a $LOG_FILE
systemctl enable jenkins &>>$LOG_FILE
Stat $?

systemctl start jenkins &>>$LOG_FILE
Stat $?

echo -e "\e[32mINSTALLATION SUCCESSFUL\e[0m"

echo -e "\n--- Configuring SSH for Jenkins user ---"
mkdir -p /var/lib/jenkins/.ssh
cat <<EOF >/var/lib/jenkins/.ssh/config
Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
EOF

chown jenkins:jenkins /var/lib/jenkins/.ssh -R
chmod 400 /var/lib/jenkins/.ssh/config
