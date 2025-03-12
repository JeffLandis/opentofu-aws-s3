variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "buckets" {
  type = any
  default = []
}

variable "bucket_pab_configurations" {
  type = any
  default = {}
}

variable "bucket_versioning_configurations" {
  type = any
  default = {}
}

variable "bucket_sse_configurations" {
  type = any
  default = {}
}

variable "bucket_acls" {
  type = any
  default = {}
}

variable "bucket_acl_grants" {
  type = any
  default = {}
}

variable "bucket_acl_grantees" {
  type = any
  default = {}
}

variable "bucket_policies" {
  type = any
  default = {}
}

variable "tags" {
  type = map(string)
  default = {}
}
