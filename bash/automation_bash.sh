aws cloudformation create-stack \
  --stack-name network-stack \
  --template-body file://network.yaml

aws cloudformation create-stack \
  --stack-name compute-stack \
  --template-body file://compute.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=myssh

aws cloudformation create-stack \
  --stack-name storage-stack \
  --template-body file://storage.yaml