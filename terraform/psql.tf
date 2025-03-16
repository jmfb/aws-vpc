locals {
  psql_name_prefix = "${local.name_prefix}-psql"
  psql_dns         = "psql.${local.root_domain}"
  psql_tags = merge(local.tags, {
    role = "psql"
    Name = local.psql_name_prefix
  })
}

resource "aws_ebs_volume" "psql" {
  availability_zone = local.availability_zone
  size              = 10
  type              = "gp2"
  tags              = local.psql_tags
}

resource "aws_security_group" "psql" {
  vpc_id      = aws_vpc.main.id
  name        = local.psql_name_prefix
  description = "Main VPC PostgreSQL Security Group"
  tags        = local.psql_tags
}

resource "aws_vpc_security_group_ingress_rule" "psql_ssh" {
  security_group_id            = aws_security_group.psql.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  tags = merge(local.psql_tags, {
    Name = "${local.psql_name_prefix}-ssh"
  })
}

resource "aws_vpc_security_group_ingress_rule" "psql_db" {
  security_group_id            = aws_security_group.psql.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  tags = merge(local.psql_tags, {
    Name = "${local.psql_name_prefix}-db"
  })
}

resource "aws_vpc_security_group_egress_rule" "psql_all" {
  security_group_id = aws_security_group.psql.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags              = local.psql_tags
}

resource "aws_instance" "psql" {
  ami                         = data.aws_ami.linux_arm64.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.bastion.key_name
  vpc_security_group_ids      = [aws_security_group.psql.id]
  associate_public_ip_address = false
  availability_zone           = local.availability_zone
  subnet_id                   = aws_subnet.private.id
  tags                        = local.psql_tags
}

resource "aws_volume_attachment" "psql" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.psql.id
  volume_id   = aws_ebs_volume.psql.id
}

resource "aws_route53_record" "psql" {
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name    = local.psql_dns
  type    = "A"
  ttl     = 300
  records = [aws_instance.psql.private_ip]
}
