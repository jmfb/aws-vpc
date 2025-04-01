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

## Connecting to EC2

You must have the vpc_bastion private key file with correct permissions:
```sh
chmod 600 ./vpc_bastion
ssh -i ./vpc_bastion ec2-user@psql.buysse.link
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

## PostgreSQL Setup

Run the following to install docker, start it, set it up for restart, and not require sudo.
```sh
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
```

Run the following exactly once to format the attached ESB volume:
NOTE: Do not run this twice or you will blow away the SQL data.
```sh
sudo mkfs -t ext4 /dev/sdh
```

Run the following when spinning up a new EC2 instance to mount the volume:
```sh
sudo mkdir -p /mnt/psql_data
sudo mount /dev/sdh /mnt/psql_data
sudo chmod 777 /mnt/psql_data
sudo vim /etc/fstab
```

Add the following line to make the mount automatic on reboot:
```fstab
/dev/sdh /mnt/psql_data ext4 defaults,nofail 0 0
```

And after mounted, create the root data directory (only need to do this the first time):
```sh
mkdir -p /mnt/psql_data/data
```

And then run the specified version of postgres with the attached data volume:
NOTE: You may need to disconnect and reconnect for permissions to take effect.
```sh
# TODO: psql_password=... password from BitWarden
docker run -d \
	--name postgres-db \
	-p 5432:5432 \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=$psql_password \
	-v /mnt/psql_data/data:/var/lib/postgresql/data \
	--restart unless-stopped \
	postgres:17.4
```
