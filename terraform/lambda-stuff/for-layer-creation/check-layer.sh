#!/usr/bin/env bash
layer="$1"

arn=$(aws lambda list-layer-versions \
  --layer-name "$layer" \
  --query 'LayerVersions[0].LayerVersionArn' \
  --output text 2>/dev/null || echo "")

if [ ! "$arn" == "None" ]; then
  jq -n --arg arn "$arn" '{"exists":"true","arn":$arn}'
else
  jq -n '{"exists":"false","arn":""}'
fi
