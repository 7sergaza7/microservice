# task2bcloud

## AWS infra provisioning
- VPC
- S3
- EKS
- ECR

## webapp +  docker image 
- build python webapp with healthz
  docker build -t common/apps .
  docker tag common/apps:latest public.ecr.aws/b6u5u6e2/common/apps:latest
  docker push public.ecr.aws/b6u5u6e2/common/apps:latest
## github actions build and  push image to ECR
-