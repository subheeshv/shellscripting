#!/bin/bash

if [ $(id -u) -ne 0 ]; then 
    echo -e "You should perform this as root user"
    exit 1
fi 

LOGFILE=/tmp/jinstall.log
Stat() {
    if [ $1 -ne 0 ]; then 
        echo "Installation Failed: Check log $LOGFILE"
        exit 2 
    fi 
}

dnf install fontconfig java-17-openjdk-devel wget -y &> $LOGFILE
Stat $?

curl -kL https://pkg.jenkins.io/redhat-stable/jenkins.repo -o /etc/yum.repos.d/jenkins.repo&>> $LOGFILE
Stat $?

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key &>> $LOGFILE
Stat $?

dnf install jenkins --nogpgcheck -y &>> $LOGFILE
Stat $?

systemctl enable jenkins &>> $LOGFILE
Stat $?

systemctl start jenkins &>> $LOGFILE
Stat $?

echo -e "\e[32m INSTALLATION SUCCESSFUL\e[0m"

mkdir -p /var/lib/jenkins/.ssh
cat <<EOF > /var/lib/jenkins/.ssh/config
Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
EOF

chown jenkins:jenkins /var/lib/jenkins/.ssh -R
chmod 400 /var/lib/jenkins/.ssh/config
