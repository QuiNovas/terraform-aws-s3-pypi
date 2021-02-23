data "aws_region" "current" {}

data "aws_s3_bucket" "log" {
  bucket = var.log_bucket_id
}

data "aws_route53_zone" "pypi" {
  name         = var.domain_name
  private_zone = false
}
