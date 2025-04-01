locals {
  name_prefix       = "main-vpc"
  root_domain       = "buysse.link"
  region            = "us-east-1"
  availability_zone = "${local.region}a"
  tags = {
    application = "main-vpc"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = local.availability_zone
}

data "aws_route53_zone" "dns_zone" {
  name         = "${local.root_domain}."
  private_zone = false
}

data "aws_ami" "linux_arm64" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^al2023-ami-\\d{4}\\.(.*)$"

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }
}
