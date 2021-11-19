# terraform-s3-cloudfront-static-website
This repository contains the terraform scripts to setup a HTTPS static website on AWS. It is hosted
on S3, fronted by Cloudfront, and using AWS Certificate Manager for TLS.

This repository would take care of the following tasks:
* Create two S3 buckets; one for website content and the other for access logs.
* Create an ACM certificate (in US-EAST-1) and using Route53 for automatic validation.
* Create a Cloudfront distribution. It uses Cloudfront Access Identity to access the S3 bucket. So
the content of the S3 doesn't need to be public and users would always access the website through
Cloudfront.
* Create a DNS record in Route53 which is an alias to the Cloudfront distribution.
* All the access logs (S3 and Cloudfront) would keep in the access log S3 bucket.
* Redirect HTTP to HTTPS

## How to use

### Prerequisites
* Install terraform: https://www.terraform.io/downloads.html
* Setup a public zone on Route53: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html
* Read `variables.tf` carefully and generate your own `tfvars` (you could take `example.tfvars` as reference)
* Deploy this terraform scripts
* Upload your static website contents to the S3 bucket

### Deploy
```
$ terraform init
$ terraform plan  -var-file example-website/example.tfvars
$ terraform apply -var-file example-website/example.tfvars
```

### Upload to S3
```
$ aws s3 sync {YOUR-WEBSITE-ROOT-DIRECTORY} s3://{S3-WEBSITE-BUCKET-NAME} --delete
```