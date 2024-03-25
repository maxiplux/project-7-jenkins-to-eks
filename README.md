# CI/CD Pipeline with Jenkins and AWS EKS for Web Application Deployment

## Overview

This project demonstrates the implementation of a Continuous Integration and Continuous Deployment (CI/CD) pipeline using Jenkins. The pipeline automates the deployment of a web application, packaged as a container, into an Amazon Web Services (AWS) Elastic Kubernetes Service (EKS) environment. This setup allows for efficient, reliable, and scalable deployment of web applications.

## Architecture

![Architecture Diagram](DevOps%20-%20Project%20-%20CI_CD.png)

The architecture involves several key components:
- **Jenkins Server:** Orchestrates the CI/CD pipeline, managing tasks from code updates to deployment.
- **GitHub:** Hosts the source code repository, triggering the Jenkins pipeline upon updates.
- **Docker:** Packages the application into a container, ensuring consistency across different environments.
- **AWS EKS:** Serves as the container orchestration platform, managing the deployed application's scaling and management.
- **Docker Hub:** Stores Docker images, allowing for easy distribution and deployment of containerized applications.

## Requirements

### Part 1: Deploy a Jenkins Server on AWS

1. Provision a Jenkins server on AWS. This can be done using various methods, such as AWS CloudFormation, Terraform, or manually through the AWS Management Console.
2. Ensure connectivity and access to the Jenkins dashboard.

### Part 2: Deploy Container Infrastructure

1. Provision an AWS EKS cluster. This can also be achieved through AWS CLI, Terraform, or other Infrastructure as Code (IaC) tools.
2. Verify the readiness of the container environment for application deployment.

### Part 3: App CI/CD with Jenkins Pipeline

- **Source:** Check out the application source code from GitHub.
- **Build:** Construct the Docker image of the application on the Jenkins server.
- **Test:** Execute application tests. If tests fail, the pipeline halts; otherwise, it proceeds.
- **Push:** On successful test completion, push the Docker image to Docker Hub.
- **Deploy:** Deploy the application into the AWS EKS cluster using Kubernetes manifest files.

## Getting Started

### Spinning Up the Jenkins Server and Container Infrastructure


1. [Full document about how to install and configure this project.](https://github.com/yourusername/yourrepository/blob/main/tutorial.docx)

2. [Video with full details.] (https://www.youtube.com/watch?v=QwN1tP6YZs4&ab_channel=JuanFranciscoMosquera)





## Acknowledgments

- Thanks to [anyone you wish to acknowledge] for their guidance and support in completing this project.
