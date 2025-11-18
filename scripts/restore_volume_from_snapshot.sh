#!/usr/bin/env bash
# Uso: ./restore_volume_from_snapshot.sh <SNAPSHOT_ID> <AVAILABILITY_ZONE>
SNAPSHOT_ID=$1
AZ=$2
REGION=${AWS_REGION:-us-east-1}
if [ -z "$SNAPSHOT_ID" ] || [ -z "$AZ" ]; then
  echo "Uso: $0 <SNAPSHOT_ID> <AVAILABILITY_ZONE>"
  exit 1
fi
aws ec2 create-volume --region "$REGION" --availability-zone "$AZ" --snapshot-id "$SNAPSHOT_ID"
