#!/bin/bash

COMPONENT=$1
ENV=$2
HOSTZONEID="Z08663422ENLYAQ21NXYT"
INSTANCE_TYPE="t2.micro"

if [ -z $1 ] || [ -z $2 ] ; then
    echo -e "\e[31m COMPONENT name is needed \e[0m \n \t \t"
    echo -e "\e[35m Ex usage \e[0m \n\t\t $ bash launch-ec2.sh shipping"
    exit 1
fi

AMI_ID="$(aws ec2 describe-images --owners 355449129696 --filters "Name=name,Values=DevOps-LabImage-rhel9"| jq ".Images[].ImageId" | sed -e 's/"//g')"
SG_ID="$(aws ec2 describe-security-groups --filters Name=group-name,Values=default | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')"

create_ec2() {
    echo -e "****** Creating \e[35m ${COMPONENT} \e[0m Server Is In Progress ************** "
    PRIVATEIP=$(aws ec2 run-instances --image-id ${AMI_ID} --instance-type ${INSTANCE_TYPE} --security-group-ids ${SG_ID} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}-${ENV}}]" | jq '.instances[].PrivateIpAddress' | sed -e 's/""//g')

    echo -e "Private IP Address of the $COMPONENT-${ENV} is $PRIVATEIP \n\n"
    echo -e "Creating DNS Record of ${COMPONENT}: "

    sed -e "s/COMPONENT/${COMPONENT}-${ENV}/" -e "s/IPADDRESS/${PRIVATEIP}/" route53.json >/tmp/r53.json

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTZONEID --change-batch file:///tmp/r53.json
    echo -e "\e[36m **** Creating DNS Record for the $COMPONENT has completed **** \e[0m \n\n"
}

if [ "$1" == "all" ] ; then
    for component in mongodb catalogue cart user shipping frontend payment mysql redis rabbitmg; do
    COMPONENT=$component
    create_ec2

    done

else
    create_ec2
fi
