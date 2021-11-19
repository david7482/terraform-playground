variable "aws_profile" {
  description = "The AWS profile which would be used to run terraform"
  default     = "david74"
}

variable "region" {
  description = "The region to create the S3 bucket and other resources."
  default     = "ap-northeast-1"
}

variable "website_name" {
  description = "The name of this static website; also for S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

# Domain name
variable "fqdn" {
  description = "The fully-qualified domain name of the resulting S3 website."
  default     = "mysite.example.com"
}

variable "domain" {
  description = "The domain name of this website"
  default     = "example.com"
}

variable "index_document" {
  description = "HTML to show at root"
  default     = "index.html"
}

variable "error_document" {
  description = "HTML to show on 404"
  default     = "404.html"
}

variable "cloudfront_price_class" {
  description = "The price class for Cloudfront"
  default     = "PriceClass_100"
}
