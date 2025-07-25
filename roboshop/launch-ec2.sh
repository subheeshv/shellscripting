#!/bin/bash

set -e  # Stop on any error

COMPONENT=$1
ENV=$2
HOSTZONEID="Z08663422ENLYAQ21NXYT"
INSTANCE_TYPE="t2.micro"

# Input validation
if [ -z "$COMPONENT" ] || [ -z "$ENV" ]; then
    echo -e "\e[31mCOMPONENT and ENV are required.\e[0m"
    echo -e "\e[33mUsage:\e[0m bash $0 <component-name> <env-name>"
    exit 1
fi

# Fetch AMI ID (your own image)
AMI_ID=$(aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=mydevops-labimage-rhel9" \
  --query "Images[0].ImageId" \
  --output text)

if [[ "$AMI_ID" == "None" || -z "$AMI_ID" ]]; then
  echo -e "\e[31mAMI not found. Check name or ownership.\e[0m"
  exit 1
fi

# Fetch default security group ID
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=default \
  --query "SecurityGroups[0].GroupId" \
  --output text)

create_ec2() {
    echo -e "\n****** Creating \e[35m${COMPONENT}\e[0m-${ENV} Server **************"

    # Launch EC2 and extract private IP
    PRIVATEIP=$(aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type "$INSTANCE_TYPE" \
      --security-group-ids "$SG_ID" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}-${ENV}}]" \
      --query "Instances[0].PrivateIpAddress" \
      --output text)

    if [[ -z "$PRIVATEIP" || "$PRIVATEIP" == "None" ]]; then
        echo -e "\e[31mFailed to get Private IP. Instance may not have launched.\e[0m"
        return
    fi

    echo -e "Private IP Address of \e[32m$COMPONENT-$ENV\e[0m is \e[36m$PRIVATEIP\e[0m"
    echo -e "Creating DNS Record for \e[35m${COMPONENT}-${ENV}\e[0m..."

    # Prepare Route53 JSON file
    sed -e "s/COMPONENT/${COMPONENT}-${ENV}/" \
        -e "s/IPADDRESS/${PRIVATEIP}/" route53.json > /tmp/r53.json

    # Create DNS record
    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTZONEID" \
      --change-batch file:///tmp/r53.json

    echo -e "\e[36m**** DNS Record for $COMPONENT created successfully ****\e[0m"
}

# Handle single or batch components
if [ "$COMPONENT" == "all" ]; then
    for comp in mongodb catalogue cart user shipping frontend payment mysql redis rabbitmq; do
        COMPONENT=$comp
        create_ec2
    done
else
    create_ec2
fi

