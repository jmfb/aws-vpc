locals {
  name_prefix       = "main-vpc"
  root_domain       = "buysse.link"
  region            = "us-east-1"
  availability_zone = "${local.region}a"
  tags = {
    application = "main-vpc"
  }
}

data "aws_route53_zone" "dns_zone" {
  name         = "${local.root_domain}."
  private_zone = false
}

data "aws_ami" "linux_arm64" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^amzn2-ami-kernel-(.*)-hvm-2\\.0\\.(.*)\\.(.*)-arm64-gp2$"

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
