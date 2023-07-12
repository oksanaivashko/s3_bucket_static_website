variable "region" {
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

# ---- certificate arn ---

variable "acm_arn" {
  default = "arn:aws:acm:us-east-1:296584602587:certificate/e1759f8d-08a7-41b8-872f-31b17475b070"
  type = string
}