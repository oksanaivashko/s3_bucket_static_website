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
  default = ""
  type = string
}