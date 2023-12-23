#!/bin/bash

# Terraform Managed Resources: This script will only destroy resources that were provisioned by 
# Terraform and are tracked in the Terraform state file of the current Terraform project. It won't affect 
# resources created outside of Terraform.
########################################## 
# Current Terraform Project: The script must be run in the directory containing the Terraform 
# configuration files (*.tf) and the corresponding state file. If you have multiple Terraform projects, 
# you'll need to run the script in each project's directory.
##########################################
# Ensure script is run with proper privileges

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Destroy the infrastructure
# This command will ask for confirmation before destroying resources.
# To avoid the prompt, use 'terraform destroy -auto-approve'
echo "Destroying the infrastructure..."
terraform destroy -auto-approve

# Check for errors in destruction
if [ $? -eq 0 ]; then
    echo "Infrastructure destroyed successfully."
else
    echo "An error occurred while destroying the infrastructure."
fi
