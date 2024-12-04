output "caller_identity" {
  value = data.aws_caller_identity.current
  description = "The effective Account ID, User ID, and ARN in which Terraform is authorized."
}

output "region" {
  value = data.aws_region.current
  description = "AWS region the buckets resides in."
}

output "buckets" {
  value = { for k,v in aws_s3_bucket.this: k => 
    {
      id = v.id
      name = v.bucket
      arn = v.arn
      region = v.region
      public_access_block = try(aws_s3_bucket_public_access_block.this[k], null)
      ownership_controls = try(aws_s3_bucket_ownership_controls.this[k], null)
      server_side_encryption = try(aws_s3_bucket_server_side_encryption_configuration.this[k], null)
      versioning = try(aws_s3_bucket_versioning.this[k], null)
      access_control_list = try(aws_s3_bucket_acl.this[k], null)
      bucket_policy = try(aws_s3_bucket_policy.this[k], null)
    }
  }
  description = <<-EOT
Map of S3 buckets.
| Attribute Name            | Description                                                   |
|---------------------------|---------------------------------------------------------------|
| id                        | Name of the bucket.                                           |
| name                      | Name of the bucket.                                           |
| arn                       | ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| region                    | AWS region this bucket resides in.                            |
| public_access_block       | Public Access Block configuration.                            |
| ownership_controls        | Bucket Ownership Controls.                                    |
| server_side_encryption    | Server side encryption configuration.                         |
| versioning                | Versioning configuration.                                     |
| access_control_list       | Access Control List.                                          |
| bucket_policy             | Bucket Policy.                                                |
EOT
}
