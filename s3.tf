resource "aws_s3_bucket" "pypi" {
  bucket = var.domain_name

  # lifecycle {
  #   prevent_destroy = true
  # }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    id                                     = "versions"
    enabled                                = true

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 60
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  dynamic "logging" {
    for_each = var.logging == true ? [var.logging] : []

    content {
      target_bucket = var.log_bucket_id
      target_prefix = "s3/${var.domain_name}/"
    }
  }

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
  }

  tags = var.tags
}

data "aws_iam_policy_document" "pypi" {
  # statement {
  #   actions = [
  #     "s3:*",
  #   ]
  #   condition {
  #     test = "Bool"
  #     values = [
  #       "false",
  #     ]
  #     variable = "aws:SecureTransport"
  #   }
  #   effect = "Deny"
  #   principals {
  #     identifiers = [
  #       "*",
  #     ]
  #     type = "AWS"
  #   }
  #   resources = [
  #     aws_s3_bucket.pypi.arn,
  #     "${aws_s3_bucket.pypi.arn}/*",
  #   ]
  #   sid = "DenyUnsecuredTransport"
  # }
  # statement {
  #   actions = [
  #     "s3:PutObject",
  #   ]
  #   condition {
  #     test = "StringNotEquals"
  #     values = [
  #       "AES256",
  #     ]
  #     variable = "s3:x-amz-server-side-encryption"
  #   }
  #   effect = "Deny"
  #   principals {
  #     identifiers = [
  #       "*",
  #     ]
  #     type = "AWS"
  #   }
  #   resources = [
  #     aws_s3_bucket.pypi.arn,
  #     "${aws_s3_bucket.pypi.arn}/*",
  #   ]
  #   sid = "DenyIncorrectEncryptionHeader"
  # }
  statement {
    actions = [
      "s3:GetObject",
    ]
    condition {
      test = "StringLike"
      values = [
        "96.58.110.21",
      ]
      variable = "aws:SourceIp"
    }
    effect = "Allow"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.pypi.arn,
      "${aws_s3_bucket.pypi.arn}/*",
    ]
    sid = "ReadObjects"
  }
}

resource "aws_s3_bucket_policy" "pypi" {
  bucket = aws_s3_bucket.pypi.id
  policy = data.aws_iam_policy_document.pypi.json
}

# resource "aws_s3_bucket_public_access_block" "pypi" {
#   count                   = var.block_all_public_access ? 1 : 0
#   bucket                  = aws_s3_bucket.pypi.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }