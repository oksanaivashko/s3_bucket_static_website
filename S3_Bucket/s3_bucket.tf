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
    bucket         = "terraform-session-september-backend-oksana"
    region         = "us-west-2"
    key            = "s3_static-web/backend/terrafrom.rfstate"
    dynamodb_table = "terraform-session-sep-state-lock"
  }
}

resource "aws_s3_bucket" "static_website" {
  bucket = "demo-s3-bucket-test-oksana-tf"
  tags = {
    Name        = "demo-s3-bucket-test-oksana-tf"
    Environment = var.env
  }
}
# ----- Static website configuration ---

resource "aws_s3_bucket_website_configuration" "static_website_configuration" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = var.index_html
  }

  error_document {
    key = var.error_html
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
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
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::demo-s3-bucket-test-oksana-tf/*"
            ]
        }
    ]

  })
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ----- cloudFront distribution with the static website ------

resource "aws_cloudfront_distribution" "static_website_distribution" {
  depends_on = [aws_s3_bucket_policy.static_website_policy]  
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_domain_name
    origin_id   = aws_s3_bucket.static_website.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_html

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_website.id

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

  resource "aws_acm_certificate" "imported_certificate" {
  certificate_arn = "arn:aws:cloudfront::296584602587:distribution/E4NAV9Q3KPPI3"
}


  viewer_certificate {
    acm_certificate_arn = "arn:aws:cloudfront::296584602587:distribution/E4NAV9Q3KPPI3"
    ssl_support_method  = "sni-only"
  }
}

# ---- Route 53 record set ----
 

resource "aws_route53_record" "cloudfront_record" {
  zone_id = "Z0480476I3YP7F1IGH87"  
  name    = "oksanai.com"           
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}