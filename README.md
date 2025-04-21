# task2bcloud

## AWS infra provisioning
- VPC
- S3
- EKS
- ECR

## webapp +  docker image 
- build python webapp with healthz
  docker build -t webapp:0.1.0 .
  docker tag webapp:0.1.0 public.ecr.aws/b6u5u6e2/common/webapp:0.1.0
  docker push public.ecr.aws/b6u5u6e2/common/webapp:0.1.0


  aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/b6u5u6e2

## github actions build and  push image to ECR
-