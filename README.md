![Project Image](vector_terraform.png)

# Vector | Terraform

Vector Terraform is an auto-provisioning system to fully deploy Redwing Vector to a cloud provider of your choice. To run the app with prompt-based auto-configuration, simply clone this repo and enter the `terraform` directory where the app is installed and run the following command:

Mac or Linux:

```bash
sh run_terraform.sh
```

Alternatively with  credentials without prompt:

```bash
sh sh run_terraform.sh "<license_key>" "<customer_id"
```

## AWS Credential Configuration

Be sure to run the app from the same terminal window, or ensure the variables are saved to your .bash_profile or .bashrc

Documentation for getting AWS Access Keys is available here, IAM roles must be configured for correct usage and access to Cloudwatch.
[AWS IAM Documentation](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html
)

Before running the application, you need to set up your AWS credentials.

Prerequisites:
Make sure you have the AWS CLI installed. If not, follow these instructions.

Edit the ~/.aws/credentials and/or ~/.aws/config files for boto to run or use the AWS CLI to update.

```bash
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

To connect to deployed box

```
ssh -i "aws_deploy_key_<id>.pem" ubuntu@<deployed_ip> -o "IdentitiesOnly yes"
```

To teardown Terraform managed cloud 

```
sudo sh destroy.sh
```

Important Notes:
Never commit your ~/.aws/credentials file to source control.
Regularly rotate your AWS access keys and always follow best security practices.
Ensure you have the necessary permissions in AWS to perform the actions required by the application.