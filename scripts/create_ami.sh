#!/usr/bin/env bash
# Uso: ./create_ami.sh <INSTANCE_ID> "Nome da AMI"
INSTANCE_ID=$1
AMI_NAME=$2
REGION=${AWS_REGION:-us-east-1}
if [ -z "$INSTANCE_ID" ] || [ -z "$AMI_NAME" ]; then
  echo "Uso: $0 <INSTANCE_ID> \"AMI_NAME\""
  exit 1
fi
aws ec2 create-image --region "$REGION" --instance-id "$INSTANCE_ID" --name "$AMI_NAME" --no-reboot
