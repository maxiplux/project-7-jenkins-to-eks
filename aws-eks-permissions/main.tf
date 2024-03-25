terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


resource "aws_iam_policy" "ec2_eks_management" {
  name        = "EC2EKSManagementPolicy"
  description = "Policy to manage EC2 instances and EKS clusters"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
       {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_policy" "cli_user_policy" {
  name        = "terraform-deployer"
  description = "Policy that grants full access to EC2 and S3 and read-only access to DynamoDB."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:*", "s3:*"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = ["dynamodb:Describe*", "dynamodb:List*", "dynamodb:Get*"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_user" "terraform_user" {
  name = "terraform-deployer"
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.ec2_eks_management.arn
}

resource "aws_iam_access_key" "terraform_user_key" {
  user = aws_iam_user.terraform_user.name
}


output "iam_user_access_key_id" {
  value       = aws_iam_access_key.terraform_user_key.id
  description = "The IAM User's Access Key ID."
}

output "iam_user_secret_access_key" {
  value       = aws_iam_access_key.terraform_user_key.secret
  description = "The IAM User's Secret Access Key."
  sensitive   = true
}
#terraform output -raw iam_user_secret_access_key
#aws sts get-caller-identity
#terraform destroy  -auto-approve
#terraform apply  -auto-approve





