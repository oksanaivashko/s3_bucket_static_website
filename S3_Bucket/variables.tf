variable "region" {
  default = "us-east-1"
  type = string
}

variable "bucket_name" {
  default = "oksanai.com"
  type = string
}

variable "env" {
  default = "demo"
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
  default = ""
  type = string
}

# --- Variables for Certificate ---

variable "dns_name" {
  default = "oksanai.com"
  type = string
}