terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "redwing_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "redwing-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "redwing_igw" {
  vpc_id = aws_vpc.redwing_vpc.id
  tags = {
    Name = "redwing-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.redwing_vpc.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.redwing_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redwing_igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a security group
resource "aws_security_group" "redwing_sg" {
  name        = "redwing-sg"
  description = "Redwing Vector Security Group"
  vpc_id      = aws_vpc.redwing_vpc.id

  # Allow inbound HTTP traffic on port 8501 for Streamlit
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redwing-sg"
  }
}

resource "aws_network_acl" "redwing_acl" {
  vpc_id = aws_vpc.redwing_vpc.id
  tags = {
    Name = "redwing-nacl"
  }
}

resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.redwing_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 8501
  to_port        = 8501
}

resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.redwing_acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.redwing_acl.id
  rule_number    = 200
  egress         = true
  protocol       = "-1" # -1 means all protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# EC2 instance
resource "aws_instance" "redwing_vector_host" {
  ami                    = "ami-05d47d29a4c2d19e1" # Choose your AMI / arm64 required for Docker image match
  instance_type          = "m6g.large" 
  key_name               = var.ec2_key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.redwing_sg.id]

  associate_public_ip_address = true

  # ssh -i "aws_deploy_key_<id>.pem" ubuntu@<public-ip>
  connection {
    type        = "ssh"
    user        = "ubuntu"  # or "ec2-user", "root", etc., depending on the AMI
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  # Provisioning commands
  # DEBIAN_FRONTEND=noninteractive: This setting prevents the installer from opening dialog boxes that require user interaction.
  # apt-get upgrade -y: The -y flag automatically answers 'yes' to all prompts.
  # Dpkg::Options::="--force-confnew": This option ensures that new configuration files replace the existing ones without prompting for confirmation.
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "export PATH=$PATH:/home/ubuntu/.local/bin",
      "echo 'export PATH=$PATH:/home/ubuntu/.local/bin' >> ~/.bashrc",      
      "source /etc/profile",
      "sudo bash -c 'cat <<EOF > /etc/needrestart/needrestart.conf\n# needrestart configuration\n\\$nrconf{restart} = a;\nEOF'",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=\"--force-confnew\"",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo apt-get install -y docker-compose vim",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "git clone https://github.com/redwing-os/sandbox.git",
      "cd sandbox", # get into directory to run docker compose
      "echo 'setting license env' ${var.license_key}",
      "echo 'setting customer_id env' ${var.customer_id}",
      "export LICENSE_KEY=${var.license_key}",
      "export CUSTOMER_ID=${var.customer_id}",      
      "sudo docker pull helloredwing/vector",
      "sudo docker-compose up -d", # -d,  # Run in detached mode # NEED TO REVERT THIS SO PROCESS ENDS
      "sleep 10",  # Short delay for initialization
      "docker ps",  # Check container status
      "docker-compose logs",  # Get initial logs
      "cd dashboard",  # Get into directory to run streamlit
      "sudo apt-get install -y libpq-dev",  # Install PostgreSQL development files
      "pip3 install psycopg2-binary",       # Install psycopg2-binary      
      "sudo apt-get install -y python3 python3-pip",
      "pip3 install --user grpcio grpcio-tools streamlit scikit-learn",
      "echo 'export PATH=$PATH:/home/ubuntu/.local/bin' >> ~/.profile",
      "echo 'set license env' ${var.license_key}",
      "echo 'set customer_id env' ${var.customer_id}",      
      "nohup /home/ubuntu/.local/bin/streamlit run network_anomaly_dashboard.py > streamlit.log 2>&1 &",
      "sleep 5",  # gives a little time for the server to start
      "cat streamlit.log"
    ]
  }

  tags = {
    Name = "RedwingVectorHost"
  }
}

variable "ec2_key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

variable "license_key" {
  description = "Redwing Vector License Key"
  type        = string
}

variable "customer_id" {
  description = "Redwing Vector Customer ID"
  type        = string
}

variable "private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}