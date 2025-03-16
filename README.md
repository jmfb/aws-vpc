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

