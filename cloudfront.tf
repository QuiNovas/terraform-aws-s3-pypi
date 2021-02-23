resource "aws_cloudfront_distribution" "pypi" {
  aliases = [
    var.domain_name
  ]

  origin {
    domain_name = "${aws_s3_bucket.pypi.id}.s3-website-${data.aws_region.current.name}.amazonaws.com"
    #domain_name = "${aws_s3_bucket.pypi.id}.s3.amazonaws.com"
    origin_id   = "${var.domain_name}-pypi"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }



    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    # }
  }

  #   custom_error_response {
  #     error_caching_min_ttl = 0
  #     error_code            = 404
  #     response_code         = 200
  #     response_page_path    = "/index.html"
  #   }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "S3 PyPi"
  #default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain_name}-pypi"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    # min_ttl                = 0
    # default_ttl            = 3600
    # max_ttl                = 86400
  }

  logging_config {
    bucket          = data.aws_s3_bucket.log.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/${var.domain_name}/"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.domain_name} PyPi"
}

resource "aws_route53_record" "pypi" {
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.pypi.domain_name
    zone_id                = aws_cloudfront_distribution.pypi.hosted_zone_id
  }

  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.pypi.zone_id
}
