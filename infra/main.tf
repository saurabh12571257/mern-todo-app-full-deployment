provider "aws" {
  region = "ap-south-1" # change to your region
}

# --- Security Group ---
resource "aws_security_group" "ec21_sg" {
  name        = "ec2-one-sg"
  description = "Allow SSH and app traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # (restrict later for security)
  }

  ingress {
    description = "App (e.g., 3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ec2_ssh_pubkey" {
  type = string
}

# --- Key Pair (use your .pub key) ---
resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = var.ec2_ssh_pubkey
}

# --- EC2 Instance ---
resource "aws_instance" "app" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t2.small"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.ec21_sg.name]

  tags = {
    Name = "docker-host"
  }
}

# --- Output the Public IP ---
output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}
