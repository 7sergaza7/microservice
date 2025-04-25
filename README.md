# task2bcloud

## AWS infra provisioning
- VPC
- S3
- EKS
- ECR

`terraform init --upgrade`
`terraform plan -var-file="dev.tfvars"`
`terraform apply -var-file="dev.tfvars" --auto-approve`

## webapp +  docker image 
- build python webapp with healthz
  docker build -t webapp:0.1.0 .
  docker tag webapp:0.1.0 public.ecr.aws/b6u5u6e2/common/webapp:0.1.0
  docker push public.ecr.aws/b6u5u6e2/common/webapp:0.1.0


  aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/b6u5u6e2

## github actions build and  push image to ECR
-


## HPA load test on webapp - manually tested

### CPU average untilization on webapp-deployment defined to 15 to make it faster and easier to check
### install metrics server as a prereq for hpa
`kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`
		
### validate metrics server working fine
`kubectl top nodes`

### running pod with busybox image to generate load
`kubectl run -i --tty load-generator --image=busybox --restart=Never -- /bin/sh`
### run load command from the load-generator pod
`while true; do wget -q -O- http://a6cb72e95c9e04de5a86bb1c7c73cbb8-893135315.us-east-1.elb.amazonaws.com; done`

### monitor the load and validate 
replicas increased

`Every 2.0s: kubectl get hpa -n webapp                              
DESKTOP-ICPB06S: Fri Apr 25 12:53:56 2025

NAME         REFERENCE                      TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
webapp-hpa   Deployment/webapp-deployment   cpu: 22%/15%   1         3         2          20m`