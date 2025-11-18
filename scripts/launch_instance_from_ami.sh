#!/usr/bin/env bash
#
# Script: launch_instance_from_ami.sh
# Descrição:
#   Lança uma nova instância EC2 baseada em uma AMI existente.
#   Permite configurar tipo de instância, par de chaves e security group.
#
# Uso:
#   ./launch_instance_from_ami.sh <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SG_ID> <SUBNET_ID>
#
# Exemplo:
#   ./launch_instance_from_ami.sh ami-0abcd1234 t3.micro minhaKey sg-0123abcd subnet-0a1b2c3d
#
# Pré-requisitos:
#   - AWS CLI v2 configurado (aws configure)
#   - Permissões: ec2:RunInstances, ec2:DescribeInstances
#

# ----------------------------
# Validação de parâmetros
# ----------------------------
if [ "$#" -lt 5 ]; then
  echo "Uso correto:"
  echo "  $0 <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SG_ID> <SUBNET_ID>"
  echo ""
  echo "Exemplo:"
  echo "  $0 ami-0abcd1234 t3.micro minhaKey sg-0123abcd subnet-0a1b2c3d"
  exit 1
fi

AMI_ID=$1
INSTANCE_TYPE=$2
KEY_NAME=$3
SECURITY_GROUP_ID=$4
SUBNET_ID=$5
REGION=${AWS_REGION:-us-east-1}

echo ""
echo "---------------------------------------------"
echo " Lançando instância a partir da AMI"
echo "---------------------------------------------"
echo " AMI ID:             $AMI_ID"
echo " Tipo da instância:  $INSTANCE_TYPE"
echo " Par de chaves:      $KEY_NAME"
echo " Security Group:     $SECURITY_GROUP_ID"
echo " Subnet:             $SUBNET_ID"
echo " Região AWS:         $REGION"
echo "---------------------------------------------"
echo ""

# ----------------------------
# Execução do comando AWS CLI
# ----------------------------
INSTANCE_JSON=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Launched-From-AMI}]" \
  --output json 2>&1)

if [ $? -ne 0 ]; then
  echo "❌ Erro ao lançar instância:"
  echo "$INSTANCE_JSON"
  exit 1
fi

INSTANCE_ID=$(echo "$INSTANCE_JSON" | jq -r '.Instances[0].InstanceId')

echo "✅ Instância criada com sucesso!"
echo " ID da instância: $INSTANCE_ID"
echo ""
echo " Consulte com:"
echo "   aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION"
echo ""

exit 0 
