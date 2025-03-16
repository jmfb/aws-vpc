# AWS VPC

Terraform for AWS VPC shared infrastructure.

## Bastion Key

You must create an SSH key pair for the bastion EC2 instance.

```sh
ssh-keygen -t ed25519 -C "AWS Bastion SSH Key Pair"
...
```

Save this to your profile `.ssh` directory with the name `vpc_bastion` and use an appropriate passphrase.
Save the public/private key pair values to your BitWarden: `VPC Bastion Private Key`.
If you need to recreate these, the file names are `vpc_bastion` for the private key and `vpc_bastion.pub` for the public key.

## Connecting to Bastion

You must have the vpc_bastion private key file with correct permissions:
```sh
chmod 600 ./vpc_bastion
ssh -i ./vpc_bastion ec2-user@bastion.buysse.link
```

## Deployment

Configure the AWS CLI to use the `deployment` IAM User credentials stored from BitWarden.

```PowerShell
$Env:TF_VAR_user_profile = $Env:USERPROFILE
cd terraform
terraform init
terraform plan
terraform apply
```

## Start/Stop Bastion

You can stop the bastion when it is not in use:

```PowerShell
$instanceId = aws ec2 describe-instances `
	--filters "Name=tag:Name,Values=main-vpc-bastion" `
	--query "Reservations[0].Instances[0].InstanceId" `
	--output text
Write-Host "[$(Get-Date)] Instance ID: $instanceId"
aws ec2 stop-instances --instance-ids $instanceId
...
aws ec2 start-instances --instance-ids $instanceId
terraform apply
```

Note that the terraform apply is to update the Route53 record since the public
IP address changes between reboots.
