variable "region" {
  default = ""
  type = string
}

variable "tf_version" {
  default = ""
  type = string
}

variable "aws_source" {
  default = ""
  type = string
}

variable "aws_version" {
  default = ""
  type = string
}

variable "bucket_name" {
  default = ""
  type = string
}

variable "env" {
  default = ""
  type = string
}

variable "index_html" {
  default = "index.html"
  type = string
}

variable "error_html" {
  default = "error.html"
  type = string
}

# ---- certificate arn ---

variable "acm_arn" {
  default = ""
  type = string
}