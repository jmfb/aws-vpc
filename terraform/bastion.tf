locals {
  bastion_name_prefix = "${local.name_prefix}-bastion"
  bastion_dns         = "bastion.${local.root_domain}"
  bastion_tags = merge(local.tags, {
    role = "bastion"
    Name = local.bastion_name_prefix
  })
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

resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.main.id
  name        = local.bastion_name_prefix
  description = "Main VPC Bastion Security Group"
  tags        = local.bastion_tags
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  tags              = local.bastion_tags
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags              = local.bastion_tags
}

resource "aws_key_pair" "bastion" {
  key_name   = local.bastion_name_prefix
  public_key = file("${var.user_profile}/.ssh/vpc_bastion.pub")
  tags       = local.bastion_tags
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.linux_arm64.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.bastion.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  availability_zone           = local.availability_zone
  subnet_id                   = aws_subnet.public.id
  tags                        = local.bastion_tags
}

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name    = local.bastion_dns
  type    = "A"
  ttl     = 300
  records = [aws_instance.bastion.public_ip]
}
