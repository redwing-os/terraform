#!/bin/bash
# ./run_mac_terraform.sh "your_license_key" "your_customer_id"

# Remove any existing key files that start with 'aws_deploy'
rm aws_deploy*

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Define a function to set the text color to cyan
echo_cyan() {
    echo "\033[0;36m$1\033[0m"
}

echo_magenta() {
    echo "\033[0;35m$1\033[0m"
}

# Install Terraform
echo "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install AWS CLI
echo "Installing AWS CLI..."
brew install awscli

# Check for LICENSE_KEY and CUSTOMER_ID parameters
if [ -z "$1" ]; then
  echo_cyan "Enter your LICENSE_KEY:"
  read LICENSE_KEY
else
  LICENSE_KEY=$1
fi
export TF_VAR_license_key="$LICENSE_KEY"

if [ -z "$2" ]; then
  echo_cyan "Enter your CUSTOMER_ID:"
  read CUSTOMER_ID
else
  CUSTOMER_ID=$2
fi
export TF_VAR_customer_id="$CUSTOMER_ID"

# Function to display a selection menu and get user input
function select_option {
    local prompt="$1"
    shift
    local options=("$@")
    local PS3="$prompt "
    select option in "${options[@]}"; do
        if [ 1 -le "$REPLY" ] && [ "$REPLY" -le "${#options[@]}" ]; then
            echo "${options[$REPLY-1]}"
            break
        else
            echo "Invalid choice. Try again."
        fi
    done
}

function get_aws_amd_instances {
    echo "a4g.micro"
    echo "a4g.small"
    echo "a4g.medium"
    echo "a4g.large"
    echo "a4g.xlarge"
    echo "a4g.2xlarge"
    echo "a6g.medium"
    echo "a6g.large"
    echo "a6g.xlarge"
    echo "a6g.2xlarge"
    echo "a6g.4xlarge"
    echo "a6g.8xlarge"
    echo "a6g.12xlarge"
    echo "a6g.16xlarge"
    echo "c7g.medium"
    echo "c7g.large"
    echo "c7g.xlarge"
    echo "c7g.2xlarge"
    echo "c7g.4xlarge"
    echo "c7g.8xlarge"
    echo "c7g.12xlarge"
    echo "c7g.16xlarge"
    echo "r7g.medium"
    echo "r7g.large"
    echo "r7g.xlarge"
    echo "r7g.2xlarge"
    echo "r7g.4xlarge"
    echo "r7g.8xlarge"
    echo "r7g.12xlarge"
    echo "r7g.16xlarge"
    echo "a6gd.metal"
    echo "c7gd.metal"
    echo "r7gd.metal"
    echo "a6g.metal"
    echo "c7g.metal"
    echo "r7g.metal"
    echo "u-6tb2.metal"
    echo "u-9tb2.metal"
    echo "u-12tb2.metal"
    echo "u-18tb2.metal"
    echo "u-24tb2.metal"
    echo "x3gd.metal"
    echo "x3gd.16xlarge"
    echo "x3gd.12xlarge"
    echo "x3gd.8xlarge"
    echo "x3gd.4xlarge"
}

# Function to get ARM64 compatible instances for AWS
function get_aws_arm_instances {
    echo "t4g.micro"
    echo "t4g.small"
    echo "t4g.medium"
    echo "t4g.large"
    echo "t4g.xlarge"
    echo "t4g.2xlarge"
    echo "m6g.medium"
    echo "m6g.large"
    echo "m6g.xlarge"
    echo "m6g.2xlarge"
    echo "m6g.4xlarge"
    echo "m6g.8xlarge"
    echo "m6g.12xlarge"
    echo "m6g.16xlarge"
    echo "c6g.medium"
    echo "c6g.large"
    echo "c6g.xlarge"
    echo "c6g.2xlarge"
    echo "c6g.4xlarge"
    echo "c6g.8xlarge"
    echo "c6g.12xlarge"
    echo "c6g.16xlarge"
    echo "r6g.medium"
    echo "r6g.large"
    echo "r6g.xlarge"
    echo "r6g.2xlarge"
    echo "r6g.4xlarge"
    echo "r6g.8xlarge"
    echo "r6g.12xlarge"
    echo "r6g.16xlarge"
    echo "m6gd.metal"
    echo "c6gd.metal"
    echo "r6gd.metal"
    echo "m6g.metal"
    echo "c6g.metal"
    echo "r6g.metal"
    echo "u-6tb1.metal"
    echo "u-9tb1.metal"
    echo "u-12tb1.metal"
    echo "u-18tb1.metal"
    echo "u-24tb1.metal"
    echo "x2gd.metal"
    echo "x2gd.16xlarge"
    echo "x2gd.12xlarge"
    echo "x2gd.8xlarge"
    echo "x2gd.4xlarge"
}

# Function to get regions for AWS
function get_aws_regions {
    echo "us-east-1"
    echo "us-east-2"
    echo "us-west-1"
    echo "us-west-2"
    echo "eu-west-1"
    echo "eu-west-2"
    echo "eu-west-3"
    echo "eu-central-1"
    echo "ap-southeast-1"
    echo "ap-southeast-2"
    echo "ap-northeast-1"
    echo "ap-northeast-2"
    echo "ap-south-1"
    echo "sa-east-1"
    echo "ca-central-1"
}

# Function to get ARM64 compatible instances for Azure
function get_azure_instances {
    echo "Standard_B2ms"
    echo "Standard_B4ms"
    echo "Standard_B8ms"
    echo "Standard_D4as_v4"
    echo "Standard_D8as_v4"
    echo "Standard_D16as_v4"
    echo "Standard_E4as_v4"
    echo "Standard_E8as_v4"
    echo "Standard_E16as_v4"
}

# Function to get regions for Azure
function get_azure_regions {
    echo "eastus"
    echo "westus"
    echo "westus2"
    echo "eastus2"
    echo "centralus"
    echo "northcentralus"
    echo "southcentralus"
    echo "northeurope"
    echo "westeurope"
    echo "uksouth"
    echo "ukwest"
    echo "francecentral"
    echo "germanywestcentral"
    echo "norwayeast"
    echo "switzerlandnorth"
}

# Function to get ARM64 compatible instances for GCP
function get_gcp_instances {
    echo "e2-medium"
    echo "e2-highmem-2"
    echo "e2-highmem-4"
    echo "e2-highmem-8"
    echo "e2-standard-2"
    echo "e2-standard-4"
    echo "e2-standard-8"
    echo "n2-standard-2"
    echo "n2-standard-4"
    echo "n2-standard-8"
    echo "n2-highmem-2"
    echo "n2-highmem-4"
    echo "n2-highmem-8"
    echo "n2-highcpu-2"
    echo "n2-highcpu-4"
    echo "n2-highcpu-8"
}

# Function to get regions for GCP
function get_gcp_regions {
    echo "us-east1"
    echo "us-east4"
    echo "us-west1"
    echo "us-west2"
    echo "us-central1"
    echo "europe-west1"
    echo "europe-west2"
    echo "europe-west3"
    echo "europe-west4"
    echo "europe-west6"
    echo "europe-north1"
    echo "asia-east1"
    echo "asia-east2"
    echo "asia-northeast1"
    echo "asia-northeast2"
    echo "asia-northeast3"
    echo "asia-south1"
    echo "asia-southeast1"
    echo "asia-southeast2"
}

# Menu for selecting the cloud provider
echo_cyan "Select Cloud Provider:"
options=("aws" "azure" "gcp")
cloud_provider=$(select_option "Enter your choice:" "${options[@]}")

case $cloud_provider in
  "aws")
    available_regions=($(get_aws_regions))
    ;;
  "azure")
    available_regions=($(get_azure_regions))
    ;;
  "gcp")
    available_regions=($(get_gcp_regions))
    ;;
  *)
    echo_magenta "Invalid choice"
    exit 1
    ;;
esac

# Selecting region
echo_cyan "Select a region:"
region=$(select_option "Enter your choice:" "${available_regions[@]}")

# Now select instance type based on the cloud provider
case $cloud_provider in
  "aws")
    echo_cyan "Select an instance type category for AWS:"
    categories=("arm" "amd")
    instance_category=$(select_option "Enter your choice:" "${categories[@]}")

    case $instance_category in
        "arm")
            available_instances=($(get_aws_arm_instances))
            ;;
        "amd")
            available_instances=($(get_aws_amd_instances))
            ;;
    esac
    ;;
  "azure")
    available_instances=($(get_azure_instances))
    ;;
  "gcp")
    available_instances=($(get_gcp_instances))
    ;;
esac

# Selecting instance type
echo_cyan "Select an instance type:"
instance_type=$(select_option "Enter your choice:" "${available_instances[@]}")

# Menu for selecting the database
echo_cyan "Select Database:"
databases=("scylladb" "cassandra")
database=$(select_option "Enter your choice:" "${databases[@]}")

export TF_VAR_database_selection="$database"

echo "You have selected Database: $database"

case $TF_VAR_database_selection in
  "scylladb")
    export TF_VAR_db_startup_cmd="--smp 1 --memory 750M --overprovisioned 1 --listen-address=0.0.0.0 --rpc-address=0.0.0.0 --broadcast-rpc-address=127.0.0.1"
    export TF_VAR_db_image="scylladb/scylla:latest"
    export TF_VAR_db_port="9042" # 7000 for cluster communication (7001 if SSL is enabled), 9042 for native protocol clients, and 7199 for JMX  
    ;;
  "cassandra")
    export TF_VAR_db_startup_cmd=""
    export TF_VAR_db_image="cassandra:latest"
    export TF_VAR_db_port="9042" # 7000 for cluster communication (7001 if SSL is enabled), 9042 for native protocol clients, and 7199 for JMX
    ;;    
#   "falcondb")
#     export TF_VAR_db_startup_cmd="--smp 1 --memory 750M --overprovisioned 1 --listen-address=0.0.0.0 --rpc-address=0.0.0.0 --broadcast-rpc-address=127.0.0.1"
#     export TF_VAR_db_image="helloredwing/falcon:latest"
#     export TF_VAR_db_port="9042" # 7000 for cluster communication (7001 if SSL is enabled), 9042 for native protocol clients, and 7199 for JMX
#     ;;
esac

echo "You have selected Cloud Provider: $cloud_provider"
echo "You have selected Region: $region"
echo "You have selected Instance Type: $instance_type"
echo "You have selected DB Type: $database"

# Generate a Docker Compose file
# envsubst < "docker-compose.template.yml" > "docker-compose.yml" # dynamic compose generation

# Function to check if the instance requires a custom enterprise license
function requires_custom_license {
    case "$1" in
        "u-"*|"x2gd."*|"*.metal")
            return 0 ;; # Return 0 (true) for instances requiring custom license
        *)
            return 1 ;; # Return 1 (false) for other instances
    esac
}

# Check if the selected instance type requires a custom enterprise license
if requires_custom_license "$instance_type"; then
    echo "The selected instance type requires a custom enterprise license. Please contact hello@redwing.ai for further assistance."
    # Add logic here to handle the process for custom enterprise license (e.g., prompt for contact info, send an automated email, etc.)
    # ...
    exit 1
fi

# Set AWS Region
export AWS_DEFAULT_REGION="$region" # Replace with your desired AWS region

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

# Navigate to Terraform directory
cd ./ # Replace with the actual path
echo "Current Directory: $(pwd)"
echo "Listing Directory Contents:"
ls -la

# Check for AWS Terraform configuration files
if [ ! -f "deploy_aws.tf" ]; then
    echo "AWS Terraform configuration file not found in the specified directory."
    exit 1
fi

# Initialize and apply Terraform
echo "Running Terraform..."
terraform init -upgrade

# Export the variables for Terraform
export TF_VAR_instance_type="$instance_type"
export TF_VAR_region="$region"
export TF_VAR_cloud_provider="$cloud_provider"

# Apply Terraform with the selected configurations. Check if the selected cloud provider is AWS, Azure, or GCP
if [ "$TF_VAR_cloud_provider" == "aws" ]; then
    # Apply Terraform configuration for AWS
    terraform apply -auto-approve 
elif [ "$TF_VAR_cloud_provider" == "azure" ]; then
    # Apply Terraform configuration for Azure
    # terraform apply -auto-approve 
    echo "Azure Support Coming Soon."
    exit 1      
elif [ "$TF_VAR_cloud_provider" == "gcp" ]; then
    # Apply Terraform configuration for GCP
    # terraform apply -auto-approve 
    echo "GCP Support Coming Soon."
    exit 1      
else
    echo "Invalid cloud provider selected."
    exit 1
fi
