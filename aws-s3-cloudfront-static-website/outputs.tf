output "s3_website_bucket" {
  value = aws_s3_bucket.website.bucket
}

output "s3_log_bucket" {
  value = aws_s3_bucket.log.bucket
}

output "website_domain_name" {
  value = "https://${var.fqdn}"
}