# task2bcloud
Author - Sergey Diner: sergaza@gmail.com

## 📌 Introduction

This project demonstrates a full DevOps workflow including infrastructure provisioning using Terraform, containerization with Docker, CI/CD automation using GitHub Actions, and deploying a web application to a managed Kubernetes service on AWS.

**Important:** The AWS ifrastructure destroyed to minimize costs on my account


## ✅ Tools Used
- **Terraform** for infrastructure as code.
- **AWS** (EKS, S3, VPC, IAM).
- **AWS cli** for user local mode
- **Docker** for container build.
- **Bash** as part of Github actions steps and user cli mode

**Important:** AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY are required for provision steps

## 🔧 1. Infrastructure Provisioning

### 📦 Resources Provisioned
- **Kubernetes Cluster**: Single node pool EKS or AKS cluster.
- **Storage Backend**: S3 bucket or Azure Storage Account for `terraform.tfstate`.
- **IAM Roles/Policies**: For EKS access and ECR image pulling.
- **Networking**: VPC/subnets (if needed), LoadBalancer service for public access.
- **ECR**: Created private registry manually before deploying webapp image

### 🚀 Provisioning Steps

The provisioning process is initially performed manually using Terraform CLI and then automated via **GitHub Actions**.

Terraform uses shared AWS modules to adhere to best practices.

**Important:** The [`backend.tf`](https://github.com/7sergaza7/task2bcloud/blob/main/terraform/backend.tf) file must be **commented out** for the first `terraform apply` and **uncommented** for the second run to migrate the state to S3.

#### 1️⃣ Initial Terraform Run:

```bash
cd terraform
terraform init -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```
#### 2️⃣ Second Terraform Run:
Ensure  is uncommented [backend.tf](https://github.com/7sergaza7/task2bcloud/blob/main/terraform/backend.tf)

```bash
terraform init --upgrade
terraform init --reconfigure
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars" --auto-approve
```

All the steps converted to github actions in [_eks.yml workflow](https://github.com/7sergaza7/task2bcloud/blob/main/.github/workflows/_eks.yml)

## WebApp - Nginx Based Docker Image with Health Check

The [webapp sources directory](9https://github.com/7sergaza7/task2bcloud/tree/main/webapp).
This project builds a Docker image based on Nginx, adds a /healthz endpoint for health checking, and pushes the image to a private AWS ECR repository under common/webapp:latest.
The application serves static content and provides a lightweight /healthz route for container health monitoring.

The AWS prerequisites befor pushing the image:

- An AWS ECR private repository created manually (common/webapp)
- Permissions provided to push to ECR (IAM access)

The build flow. All the steps below converted to github actions steps in [_webapp.yml workflow](https://github.com/7sergaza7/task2bcloud/blob/main/.github/workflows/_webapp.yml)
```bash
 [ docker build -t webapp ./webapp ]
         ↓
 [ docker tag webapp:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/common/webapp:latest ]
         ↓
 [ docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/common/webapp:latest ]
```

## Applying kubernetes webapp manifests on EKS cluster:

This repository contains Kubernetes manifests located in the [`k8s`](https://github.com/7sergaza7/task2bcloud/tree/main/k8s) directory. These manifests define the desired state webapp application (webapp image from ECR registry) and exposing it as external ip using LoadBalancer. 
The manifests can be applied to EKS cluster using `kubectl` manually or automatically in github actions.

🛠 Prerequisites:
- Ensure access to an EKS cluster (if not, configure it using):
  ```sh
  aws eks update-kubeconfig --name <cluster name> --region <region>
- `kubectl` is installed and configured to interact with the cluster.

🚀 Manual Deployment:
  ```sh
  kubectl apply -f k8s/
  kubectl get all -n webapp
  ```

🌎 Retrieve WebApp External IP (after applying manifests):
- kubectl:
  ```sh
  kubectl get svc webapp-svc -n webapp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  ```
- using script [get_webapp.sh](https://github.com/7sergaza7/task2bcloud/blob/main/k8s/get_webapp.sh)

The applying manifiests steps on EKS implemented to github actions in [_k8s.yml workflow](https://github.com/7sergaza7/task2bcloud/blob/main/.github/workflows/_k8s.yml).


## ⚡ GitHub Actions CI/CD Pipelines

GitHub Actions workflows automate the deployment process.
Workflows directory: [.github](https://github.com/7sergaza7/task2bcloud/tree/main/.github/workflows)


🚀 Pipelines:
- Full CI/CD Pipeline (Triggered manually) – [full-cicd-webapp](https://github.com/7sergaza7/task2bcloud/).
- WebApp Build & Push (Triggered automatically) – [webapp image - build and push](https://github.com/7sergaza7/task2bcloud/actions/runs/14668275151).
- K8s Manifests Deployment (Triggered automatically) – [deploy-webapp-to-k8s](https://github.com/7sergaza7/task2bcloud/actions/runs/14668311103).
- AWS Infrastructure Provisioning (Triggered automatically) – [terraform-eks-cluster](https://github.com/7sergaza7/task2bcloud/actions/runs/14668311094).


## 🔥 Load Testing with HPA (Horizontal Pod Autoscaling)

The webapp-deployment HPA target CPU utilization is set to 15%, making it easy to observe autoscaling behavior.


🛠 Prerequisites:
- Install the metrics server:
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```
- Validate the metrics server:
  ```kubectl top nodes```

🚀 Load Generation for HPA Testing:
- Run a pod with BusyBox image:
  ```bash
  kubectl run -i --tty load-generator --image=busybox --restart=Never -- /bin/sh
  ```
- Start generating load from the load-generator pod:

  ```bash
  while true; do wget -q -O- http://a6cb72e95c9e04de5a86bb1c7c73cbb8-893135315.us-east-1.elb.amazonaws.com; done
  ```
- Monitor HPA scaling:
  ```bash
  watch kubectl get hpa -n webapp
  ```
  
  Example output when scaling occurs:

  ```bash
  Every 2.0s: kubectl get hpa -n webapp

  NAME         REFERENCE                      TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
  webapp-hpa   Deployment/webapp-deployment   cpu: 22%/15%   1         3         2          20m
  ```

🔄 Planned Improvements
- Convert Kubernetes manifests into Helm charts or use Kustomize to eliminate hardcoded values (e.g., names, replicas, image URIs).
- Implement versioning for the webapp Docker image to avoid continuously pushing to latest.
- Establish branch protection rules on main, requiring pull requests before merging.
- Implement tagging for proper versioning and release management.