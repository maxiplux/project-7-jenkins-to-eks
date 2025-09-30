# CI/CD Pipeline with Jenkins and AWS EKS for Web Application Deployment

## Overview

This project demonstrates a complete end-to-end implementation of a Continuous Integration and Continuous Deployment (CI/CD) pipeline using Jenkins and AWS infrastructure. The pipeline automates the entire workflow from code commit to production deployment, packaging a web application as a Docker container and deploying it to an Amazon Elastic Kubernetes Service (EKS) cluster.

**Key Features:**
- Fully automated CI/CD pipeline with Jenkins
- Infrastructure as Code (IaC) using Terraform
- Container orchestration with Kubernetes on AWS EKS
- Automated testing and deployment stages
- Docker-based application packaging
- Production-ready AWS infrastructure setup

## Architecture

![Architecture Diagram](DevOps%20-%20Project%20-%20CI_CD.png)

The architecture involves several key components working together:

- **Jenkins Server:** Orchestrates the entire CI/CD pipeline, managing tasks from code checkout to deployment. Runs on AWS EC2 with Docker support.
- **GitHub:** Hosts the source code repository and triggers the Jenkins pipeline automatically upon code updates.
- **Docker:** Packages the application into containers, ensuring consistency across development, testing, and production environments.
- **AWS EKS:** Serves as the container orchestration platform, managing the deployed application's scaling, high availability, and lifecycle management.
- **Docker Hub:** Acts as the container registry, storing and distributing Docker images across the deployment pipeline.
- **Kubernetes:** Manages application deployment, scaling, and operations using declarative manifest files.

## Prerequisites

Before getting started, ensure you have the following:

### Required Tools
- **AWS CLI** (v2.x or later) - [Installation Guide](https://aws.amazon.com/cli/)
- **kubectl** - Kubernetes command-line tool - [Installation Guide](https://kubernetes.io/docs/tasks/tools/)
- **eksctl** - EKS cluster management tool - [Installation Guide](https://eksctl.io/installation/)
- **Terraform** (v1.0 or later) - Infrastructure as Code tool - [Installation Guide](https://www.terraform.io/downloads)
- **Docker** - Container platform - [Installation Guide](https://docs.docker.com/get-docker/)
- **Git** - Version control system

### AWS Requirements
- Active AWS account with appropriate billing enabled
- AWS IAM user with administrative permissions or the following minimum permissions:
  - EC2 full access
  - EKS full access
  - IAM role creation permissions
  - VPC and networking permissions
- AWS credentials configured locally (`aws configure`)

### Additional Requirements
- Docker Hub account for storing container images
- GitHub account (if using GitHub webhooks for automation)
- Basic knowledge of Kubernetes, Docker, and CI/CD concepts

## Project Structure

```
project-7-jenkins-to-eks/
├── aws-eks-cluster/          # EKS cluster configuration
│   ├── cluster.yaml          # EKS cluster definition
│   ├── eks-installer.sh      # EKS setup utilities
│   ├── install-cluster.sh    # Cluster installation script
│   └── delete-cluster.sh     # Cluster cleanup script
├── aws-eks-permissions/      # IAM roles and permissions
│   └── main.tf               # Terraform configuration for AWS permissions
├── aws-jenkins-machine/      # Jenkins server setup
│   ├── terraform/            # Terraform configs for Jenkins EC2
│   │   ├── main.tf           # EC2 instance and network configuration
│   │   └── check_status.sh   # Health check script
│   ├── docker-compose.yml    # Jenkins container configuration
│   └── is-running-jenkins.sh # Jenkins status checker
├── jenkins-image/            # Custom Jenkins Docker image
│   └── Dockerfile            # Jenkins image with required plugins
├── k8s/                      # Kubernetes manifests
│   ├── namespace.yml         # Namespace definition
│   ├── deployment.yml        # Application deployment configuration
│   └── service.yaml          # Service exposure configuration
├── doc/                      # Documentation
│   └── tutorial.docx         # Detailed setup tutorial
└── README.md                 # This file
```

## Getting Started

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd project-7-jenkins-to-eks
```

### Step 2: Configure AWS Credentials

Ensure your AWS credentials are properly configured:

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, region, and output format
```

Verify the configuration:
```bash
aws sts get-caller-identity
```

### Step 3: Deploy Jenkins Server on AWS

The Jenkins server is deployed using Terraform on an AWS EC2 instance.

```bash
cd aws-jenkins-machine/terraform
terraform init
terraform plan
terraform apply
```

**Note:** Review the Terraform plan carefully before applying. The script will:
- Create a VPC and necessary networking components
- Launch an EC2 instance for Jenkins
- Configure security groups
- Set up Jenkins using Docker Compose

After deployment, retrieve the Jenkins URL and initial admin password:
```bash
./check_status.sh
```

Access Jenkins at `http://<ec2-public-ip>:8080` and complete the initial setup.

### Step 4: Configure Jenkins

1. Install required Jenkins plugins:
   - Docker Pipeline
   - Kubernetes CLI
   - Git plugin
   - Pipeline plugin
   
2. Configure Jenkins credentials:
   - Docker Hub credentials (username and password)
   - AWS credentials (access key and secret key)
   - GitHub credentials (if using private repositories)

3. Set up AWS CLI and kubectl on the Jenkins server

### Step 5: Deploy AWS EKS Cluster

Navigate to the EKS cluster directory and run the installation script:

```bash
cd aws-eks-cluster
./install-cluster.sh
```

This script will:
- Create an EKS cluster using `eksctl`
- Configure node groups
- Set up necessary IAM roles and permissions
- Configure kubectl to communicate with the cluster

Verify the cluster is running:
```bash
kubectl get nodes
kubectl get namespaces
```

### Step 6: Set Up AWS Permissions

Configure the necessary IAM roles and permissions:

```bash
cd aws-eks-permissions
terraform init
terraform apply
```

This sets up:
- EKS cluster roles
- Node group roles
- Service account permissions

### Step 7: Deploy Kubernetes Resources

Create the namespace and deploy the application manifests:

```bash
cd k8s
kubectl apply -f namespace.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yaml
```

Verify the deployment:
```bash
kubectl get pods -n <your-namespace>
kubectl get services -n <your-namespace>
```

### Step 8: Configure Jenkins Pipeline

1. Create a new Pipeline job in Jenkins
2. Configure the pipeline to pull from your GitHub repository
3. Set up webhook triggers (optional but recommended)
4. The Jenkinsfile should include stages for:
   - Source checkout
   - Docker image build
   - Running tests
   - Pushing to Docker Hub
   - Deploying to EKS

### Step 9: Test the Pipeline

1. Commit and push changes to your repository
2. Monitor the Jenkins pipeline execution
3. Verify the application is deployed and running in EKS

## Pipeline Workflow

The Jenkins CI/CD pipeline follows these stages:

### 1. Source Stage
- Checks out the latest code from the GitHub repository
- Triggered automatically on git push or pull request (with webhook)

### 2. Build Stage
- Constructs the Docker image using the application's Dockerfile
- Tags the image with build number and latest tag
- Runs on the Jenkins server with Docker installed

### 3. Test Stage
- Executes automated tests (unit tests, integration tests)
- **Pipeline stops here if tests fail**
- Only proceeds to next stage on successful test completion

### 4. Push Stage
- Authenticates with Docker Hub using stored credentials
- Pushes the Docker image to Docker Hub registry
- Makes the image available for deployment

### 5. Deploy Stage
- Updates Kubernetes deployment with the new image
- Uses kubectl to apply changes to the EKS cluster
- Kubernetes handles rolling update with zero downtime
- Verifies deployment success

## Configuration

### Customizing the Jenkins Setup

Edit `aws-jenkins-machine/docker-compose.yml` to customize Jenkins configuration:
- Change ports
- Modify volume mounts
- Add environment variables

### Customizing the EKS Cluster

Edit `aws-eks-cluster/cluster.yaml` to adjust:
- Instance types
- Number of nodes
- AWS region
- Cluster name

### Customizing Kubernetes Deployments

Modify files in the `k8s/` directory:
- `deployment.yml`: Adjust replicas, resource limits, container image
- `service.yaml`: Change service type (LoadBalancer, NodePort, ClusterIP)
- `namespace.yml`: Change namespace name

## Troubleshooting

### Jenkins Issues

**Problem:** Cannot access Jenkins dashboard
- **Solution:** Check EC2 security group allows inbound traffic on port 8080
- Verify EC2 instance is running: `aws ec2 describe-instances`
- Check Jenkins logs: `docker logs jenkins` (on the EC2 instance)

**Problem:** Jenkins pipeline fails at Docker build
- **Solution:** Ensure Docker is installed and running on Jenkins server
- Verify Jenkins user has Docker permissions
- Check Dockerfile syntax

### EKS Issues

**Problem:** kubectl cannot connect to cluster
- **Solution:** Update kubeconfig: `aws eks update-kubeconfig --name <cluster-name> --region <region>`
- Verify AWS credentials have EKS permissions
- Check cluster status: `eksctl get cluster`

**Problem:** Pods stuck in Pending state
- **Solution:** Check node resources: `kubectl describe nodes`
- Verify node group is running: `eksctl get nodegroup --cluster <cluster-name>`
- Check pod events: `kubectl describe pod <pod-name>`

**Problem:** Service not accessible
- **Solution:** Verify service type is LoadBalancer if external access needed
- Check security groups allow traffic to NodePort range (30000-32767)
- Get LoadBalancer DNS: `kubectl get svc`

### Deployment Issues

**Problem:** Image pull errors
- **Solution:** Verify Docker Hub credentials are correct in Jenkins
- Ensure image exists in Docker Hub repository
- Check imagePullSecrets in deployment.yml if using private registry

**Problem:** Application not starting
- **Solution:** Check pod logs: `kubectl logs <pod-name>`
- Verify environment variables and configuration
- Check resource limits aren't too restrictive

## Additional Resources

### Documentation
- [Full installation and configuration tutorial](./doc/tutorial.docx)
- [Video walkthrough with complete details](https://www.youtube.com/watch?v=QwN1tP6YZs4&ab_channel=JuanFranciscoMosquera)

### Useful Commands

**EKS Management:**
```bash
# List clusters
eksctl get cluster

# Delete cluster (cleanup)
./aws-eks-cluster/delete-cluster.sh

# Scale node group
eksctl scale nodegroup --cluster=<name> --name=<nodegroup-name> --nodes=<count>
```

**Kubernetes Operations:**
```bash
# View all resources
kubectl get all -n <namespace>

# Watch pod status
kubectl get pods -w

# Port forward for local testing
kubectl port-forward svc/<service-name> 8080:80

# View logs
kubectl logs -f <pod-name>
```

**Jenkins Management:**
```bash
# Check Jenkins status
./aws-jenkins-machine/is-running-jenkins.sh

# Restart Jenkins
docker restart jenkins
```

## Cleanup

To avoid AWS charges, clean up resources when done:

```bash
# Delete EKS cluster
cd aws-eks-cluster
./delete-cluster.sh

# Destroy Jenkins infrastructure
cd aws-jenkins-machine/terraform
terraform destroy

# Remove AWS permissions
cd aws-eks-permissions
terraform destroy
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## License

This project is provided as-is for educational and demonstration purposes.

## Acknowledgments

- Special thanks to the DevOps and Cloud Engineering community for best practices and guidance
- AWS documentation for EKS and infrastructure setup
- Jenkins community for plugin development and support
