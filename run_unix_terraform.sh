#!/bin/bash

# Install Terraform
echo "Installing Terraform..."
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Initialize and apply Terraform
echo "Running Terraform..."
# cd path/to/your/terraform/folder # Replace with the path to your Terraform script's directory
terraform init
terraform apply -auto-approve
