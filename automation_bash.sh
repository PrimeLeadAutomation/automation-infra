aws cloudformation create-stack \
  --stack-name network-stack \
  --template-body file://network_automation.yaml

aws cloudformation create-stack \
  --stack-name compute-stack \
  --template-body file://compute_automation.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=myssh

aws cloudformation create-stack \
  --stack-name storage-stack \
  --template-body file://storage_automation.yaml

aws cloudformation create-stack \
  --stack-name message-stack \
  --template-body file://message_automation.yaml