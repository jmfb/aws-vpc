locals {
  name_prefix       = "main-vpc"
  root_domain       = "buysse.link"
  region            = "us-east-1"
  availability_zone = "${local.region}a"
  tags = {
    application = "main-vpc"
  }
}
