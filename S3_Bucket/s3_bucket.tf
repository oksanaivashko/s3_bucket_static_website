provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 1.5.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-backend-oksana"
    region         = "us-east-1"
    key            = "s3_static-web-test/backend/terrafrom.rfstate"
    dynamodb_table = "terraform-state-lock"
  }
}

# ----- Create s3 Bucket

resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.env
  }

website {
    index_document = var.index_html
    error_document = var.error_html
  }

}

resource "aws_s3_bucket_public_access_block" "public_acl" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# ------ S3 Bucket Policies -------

resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    

    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*"
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::oksanai.com/*"
           
        }
    ]
  })     
}

locals {
  s3_origin_id = var.bucket_name
}


# ----- Create Certificate -----

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.dns_name
  subject_alternative_names = ["oksanai.com", "www.oksanai.com"]
  validation_method = "DNS" 
  tags = {
    Environment = var.env
  }
}

  resource "aws_acm_certificate_validation" "oksanai_com" {
  certificate_arn = aws_acm_certificate.certificate.arn

  validation_record_fqdns = [
    aws_route53_record.oksanai_com.fqdn,
  ] 
}

resource "aws_acm_certificate_validation" "www_oksanai_com" {
  certificate_arn = aws_acm_certificate.certificate.arn

  validation_record_fqdns = [
    aws_route53_record.www_oksanai_com.fqdn,
  ] 
}

resource "aws_route53_record" "oksanai_com" {
  zone_id = "Z0480476I3YP7F1IGH87"
  name    = "oksanai.com"
  type    = "CNAME"
  ttl     = 300
  records = aws_acm_certificate.certificate.domain_validation_options[*].resource_record_value
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "www_oksanai_com" {
  zone_id = "Z0480476I3YP7F1IGH87"
  name    = "www.oksanai.com"
  type    = "CNAME"
  ttl     = 300
  records = aws_acm_certificate.certificate.domain_validation_options[*].resource_record_value
  lifecycle {
    create_before_destroy = true
  }
}

# ----- Create Couldfront distribution with the static website ------

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_html

  aliases = ["oksanai.com", "www.oksanai.com"]

  default_cache_behavior {
  allowed_methods  = ["GET", "HEAD"]
  cached_methods   = ["GET", "HEAD"]
  target_origin_id = local.s3_origin_id

  forwarded_values {
    query_string = false

    cookies {
      forward = "none"
    }
  }

  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400
 }
  
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.id
    ssl_support_method  = "sni-only"
  }
}

# ---- Route 53 record set ----

resource "aws_route53_record" "cloudfront_record_a" {
  zone_id = "Z0480476I3YP7F1IGH87"  
  name    = "oksanai.com"           
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_record_b" {
  zone_id = "Z0480476I3YP7F1IGH87"  
  name    = "www.oksanai.com"           
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}