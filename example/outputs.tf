output "s3" {
  value = module.s3
}

output "pricing" {
  value = local.storage_pricing
}

# output "bucket_acl_grantees" {
#   value = local.bucket_acl_grantees
# }

# output "bucket_acls" {
#   value = local.bucket_acls
# }