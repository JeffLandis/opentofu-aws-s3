output "caller_identity" {
  value = data.aws_caller_identity.current
}

output "region" {
  value = data.aws_region.current
}

output "buckets" {
  value = aws_s3_bucket.this
}

output "bucket_pab_configurations" {
  value = aws_s3_bucket_public_access_block.this
}

output "bucket_ownership_controls" {
  value = aws_s3_bucket_ownership_controls.this
}

output "bucket_acls" {
  value = aws_s3_bucket_acl.this
}

output "bucket_sse_configurations" {
  value = aws_s3_bucket_server_side_encryption_configuration.this
}

output "bucket_versioning_configurations" {
  value = local.bucket_versioning_configurations
}
