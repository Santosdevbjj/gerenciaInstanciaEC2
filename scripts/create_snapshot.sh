#!/usr/bin/env bash
# Uso: ./create_snapshot.sh <VOLUME_ID> "Descrição"
VOLUME_ID=$1
DESCRIPTION=$2
REGION=${AWS_REGION:-us-east-1}
if [ -z "$VOLUME_ID" ]; then
  echo "Uso: $0 <VOLUME_ID> [descricao]"
  exit 1
fi
aws ec2 create-snapshot --region "$REGION" --volume-id "$VOLUME_ID" --description "${DESCRIPTION:-snapshot-created-by-script}"
