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


resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-pem-ansible-dec04"
  public_key = tls_private_key.ssh.public_key_openssh


}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "terraform-pem-ansible-dec04.pem"
  file_permission = "0600"
}



# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Terraform"
  }
}
resource "aws_internet_gateway" "terraform_vpc_internet_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "Terraform"
  }
}
resource "aws_route_table" "terraform_aws_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_vpc_internet_gateway.id
  }
}



resource "aws_subnet" "terraform_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform"
  }
}
resource "aws_eip" "terraform_eip" {
  vpc = true
  tags = {
    Name = "Terraform"
  }
}
resource "aws_nat_gateway" "terraform_aws_nat_gateway" {
  allocation_id = aws_eip.terraform_eip.id
  subnet_id     = aws_subnet.terraform_subnet.id
  tags = {
    Name = "Terraform"
  }
  depends_on = [aws_internet_gateway.terraform_vpc_internet_gateway]

}



resource "aws_route_table_association" "terraform_aws_route_table_association" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_aws_route_table.id
}

resource "aws_network_interface" "terraform_network_interface" {
  subnet_id   = aws_subnet.terraform_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "Terraform",
  }
}

# ------------------------------------------------------
# Define un grupo de seguridad con acceso al puerto 8080
# ------------------------------------------------------
resource "aws_security_group" "terraform_security_group" {
  name   = "terraform_security_group-sg"
  vpc_id = aws_vpc.terraform_vpc.id
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "HTTP access"
    from_port        = 8080
    to_port          = 50000
    protocol         = "TCP"
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform",
  }
}



resource "aws_security_group" "terraform_security_icmp_group" {
  name   = "terraform_security_group-icmp-sg"
  vpc_id = aws_vpc.terraform_vpc.id
  ingress {
    //cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto ICMP desde el exterior"

    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Terraform",
  }
}

resource "aws_security_group" "terraform_security_ssh_group" {
  name   = "terraform_security_ssh_group-sg"
  vpc_id = aws_vpc.terraform_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 22 desde el exterior"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
  }

  tags = {
    Name = "Terraform",
  }
}
provider "tls" {}



resource "aws_instance" "terraform_instance_master" {
  ami      = "ami-080e1f13689e07408"
  key_name = aws_key_pair.generated_key.key_name

  instance_type = "t2.medium"
  ebs_block_device {
    device_name = "/dev/sda1"  # The device name might vary based on the instance type and OS
    volume_type = "gp2"        # General Purpose SSD
    volume_size = 100           # Size of the volume in GiB
    delete_on_termination = true
  }

  subnet_id     = aws_subnet.terraform_subnet.id


  vpc_security_group_ids = [aws_security_group.terraform_security_icmp_group.id, aws_security_group.terraform_security_group.id, aws_security_group.terraform_security_ssh_group.id]
  tags = {
    Name = "Master",
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get install ec2-instance-connect wget -y
              sudo apt-get install ca-certificates curl -y
              sudo apt-get update
              sudo apt-get install ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc

              # Add the repository to Apt sources:
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update



              sudo apt-get install awscli curl mc htop python3-pip docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git -y

              cd /tmp && curl -LO  https://dl.k8s.io/release/v1.23.0/bin/linux/amd64/kubectl && sudo chmod +x ./kubectl && sudo mv  kubectl /usr/local/bin

              RUN cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo sh ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

              sudo usermod -aG docker ubuntu
              sudo chmod a+rwx /var/run/docker.sock
              sudo touch  /var/run/docker.sock && sudo chown jenkins:jenkins /var/run/docker.sock
              sudo service docker start

              cd /tmp && curl -LO  https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv kubectl /usr/local/bin
              cd /tmp && https://raw.githubusercontent.com/maxiplux/project-7-jenkins-to-eks/main/aws-jenkins-machine/docker-compose.yml
              cd /tmp && docker compose up -d
              docker exec -it jenkins  /etc/init.d/jenkins start
              echo "echo found" > /tmp/STATUS
              EOF
}





resource "null_resource" "user_data_status_check" {

  provisioner "local-exec" {
    command = "bash check_status.sh \"http://${aws_instance.terraform_instance_master.public_dns}:8080/\""
  }
  triggers = {
    #remove this once you test it out as it should run only once
    always_run = "${timestamp()}"

  }
  depends_on = [aws_instance.terraform_instance_master]

}

output "server_private_ip" {
  value = [aws_instance.terraform_instance_master.private_ip]
}

output "server_public_dns" {
  value = "http://${aws_instance.terraform_instance_master.public_dns}:8080/"
}

output "server_public_ipv4" {
  value = [aws_instance.terraform_instance_master.public_ip]
}
output "server_id" {
  value = [aws_instance.terraform_instance_master.id]
}

//terraform output -raw private_key > terraform.pem
output "private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

