############################################################
# Terraform main.tf for Elasticsearch EC2 Masters with managed SSH key
############################################################

provider "aws" {
  region = "il-central-1"
}

#-----------------------------------
# Generate a new SSH key pair locally
#-----------------------------------
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Write the private key to a local file (for Ansible to use)
resource "local_file" "deployer_private_key" {
  content          = tls_private_key.deployer.private_key_pem
  filename         = "${path.module}/deployer-key.pem"
  file_permission  = "0600"
}

# Create the AWS key pair using the generated public key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.deployer.public_key_openssh
}

#-----------------------------------
# Security Group for Elasticsearch
#-----------------------------------
resource "aws_security_group" "es_sg" {
  name        = "es-sg"
  description = "Allow SSH, Elasticsearch HTTP & transport, and Kibana"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Elasticsearch HTTP
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch REST API"
  }

  # Elasticsearch transport
  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch cluster transport"
  }

  # Kibana HTTP
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kibana web interface"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
#-----------------------------------
# AMI Lookup (Ubuntu 22.04 LTS)
#-----------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#-----------------------------------
# Elasticsearch Master Instances
#-----------------------------------
resource "aws_instance" "es_master" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.es_sg.id]

  tags = {
    Name  = "es-master${count.index + 1}"
    Group = "elasticsearch"
    Role  = "master"
  }
}

#-----------------------------------
# Outputs for Ansible Dynamic Inventory
#-----------------------------------
output "es_master_private_ips" {
  description = "Private IPs of Elasticsearch master nodes"
  value       = aws_instance.es_master.*.private_ip
}

output "ansible_private_key_path" {
  description = "Path to the generated private key for Ansible"
  value       = local_file.deployer_private_key.filename
}
