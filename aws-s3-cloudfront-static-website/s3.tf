resource "aws_s3_bucket" "log" {
  bucket = "${var.website_name}-log"
  acl    = "log-delivery-write"

  lifecycle_rule {
    enabled = true
    expiration {
      days = 30
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.website_name}-log"
    },
  )
}

resource "aws_s3_bucket" "website" {
  bucket = var.website_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.log.id
    target_prefix = "s3-access-logs/"
  }

  versioning {
    enabled = false
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.website_name
    },
  )
}

# Add Read Permission of Bucket Policy for CloudFront
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.s3_site_policy.json
}

data "aws_iam_policy_document" "s3_site_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}
