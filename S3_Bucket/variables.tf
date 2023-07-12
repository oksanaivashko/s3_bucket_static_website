variable "region" {
  default = "us-west-2"
  type = string
}

variable "bucket_name" {
  default = "demo-s3-bucket-test-oksana-tf"
  type = string
}

variable "env" {
  default = "dev"
  type = string
}

variable "index_html" {
    default = "index.html"
    type = string
}
variable "error_html" {
  default = "error_html"
  type = string
}
# ---- certificate arn ---

variable "acm_arn" {
  default = "arn:aws:acm:us-east-1:296584602587:certificate/e1759f8d-08a7-41b8-872f-31b17475b070"
  type = string
}