#!/usr/bin/env bash
# Ordem: network → message → compute → monitoring → storage.
set -euo pipefail
cd "$(dirname "$0")"

aws cloudformation create-stack \
  --stack-name network-stack \
  --template-body file://net/network_automation.yaml
aws cloudformation wait stack-create-complete --stack-name network-stack

aws cloudformation create-stack \
  --stack-name message-stack \
  --template-body file://message_automation/message_automation.yaml
aws cloudformation wait stack-create-complete --stack-name message-stack

aws cloudformation create-stack \
  --stack-name compute-stack \
  --template-body file://computing/compute_automation.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=myssh \
    ParameterKey=GitHubToken,ParameterValue="${GITHUB_TOKEN:?defina GITHUB_TOKEN}" \
    ParameterKey=DbPassword,ParameterValue="${DB_PASSWORD:?defina DB_PASSWORD}"
aws cloudformation wait stack-create-complete --stack-name compute-stack

aws cloudformation create-stack \
  --stack-name monitoring-stack \
  --template-body file://monitoring/monitoring_automation.yaml
aws cloudformation wait stack-create-complete --stack-name monitoring-stack

aws cloudformation create-stack \
  --stack-name storage-stack \
  --template-body file://storage/storage_automation.yaml
aws cloudformation wait stack-create-complete --stack-name storage-stack
