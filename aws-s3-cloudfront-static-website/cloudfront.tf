resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.website_name
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.website_name
  default_root_object = var.index_document
  price_class         = var.cloudfront_price_class
  wait_for_deployment = false
  aliases             = [var.fqdn]

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log.bucket_domain_name
    prefix          = "cloudfront-website-logs"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  # If there is a 404 or 403, return error page with a HTTP 404 Response
  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 300
    response_code         = 404
    response_page_path    = "/${var.error_document}"
  }
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 300
    response_code         = 404
    response_page_path    = "/${var.error_document}"
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.website.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 3600
    min_ttl                = 0
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.website_name
    },
  )
}
