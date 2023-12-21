#!/bin/bash
# ./run_mac_terraform.sh "your_license_key" "your_customer_id"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Terraform
echo "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install AWS CLI
echo "Installing AWS CLI..."
brew install awscli

# Set AWS Region
export AWS_DEFAULT_REGION="us-east-1" # Replace with your desired AWS region

# Generate a unique key name # To-do: return error if max limit of 16 key pairs is reached
KEY_NAME="aws_deploy_key_$(openssl rand -hex 5)"
KEY_FILE="${KEY_NAME}.pem"

# Generate SSH key pair
echo "Generating SSH key pair..."
ssh-keygen -t rsa -b 2048 -f ${KEY_FILE} -N ""

# After generating the SSH key pair
PRIVATE_KEY_PATH="$(pwd)/${KEY_FILE}"
export TF_VAR_private_key_path="${PRIVATE_KEY_PATH}"

# Upload the public key to AWS
echo "Uploading public key to AWS..."
aws ec2 import-key-pair --key-name "${KEY_NAME}" --public-key-material fileb://${KEY_FILE}.pub

# Set environment variable for the key name
export TF_VAR_ec2_key_name="${KEY_NAME}"

# Check for LICENSE_KEY and CUSTOMER_ID parameters
if [ -z "$1" ]; then
  echo "Enter your LICENSE_KEY:"
  read LICENSE_KEY
else
  LICENSE_KEY=$1
fi
export TF_VAR_license_key="$LICENSE_KEY"

if [ -z "$2" ]; then
  echo "Enter your CUSTOMER_ID:"
  read CUSTOMER_ID
else
  CUSTOMER_ID=$2
fi
export TF_VAR_customer_id="$CUSTOMER_ID"

# Navigate to Terraform directory
cd ./ # Replace with the actual path
echo "Current Directory: $(pwd)"
echo "Listing Directory Contents:"
ls -la

# Check for Terraform configuration files
if [ ! -f "deploy.tf" ]; then
    echo "Terraform configuration file not found in the specified directory."
    exit 1
fi

# Initialize and apply Terraform
echo "Running Terraform..."
terraform init -upgrade
terraform apply -auto-approve
