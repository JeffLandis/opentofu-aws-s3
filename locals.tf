locals {
  buckets = { 
  for val in var.buckets: coalesce(val.name, val.prefix) => merge(
      val,
      {
        bucket = (
          val.name != null
          ? val.name
          : join("-",
          [
            val.prefix,
            replace(data.aws_region.current.name, "-", ""),
            data.aws_caller_identity.current.account_id,
            random_string.bucket_name_suffixes[val.prefix].result
          ])
        )
      }
    )
  }

  bucket_pab_configurations = merge(
    {
      default = {
        block_public_acls = true
        ignore_public_acls = true
        block_public_policy = true
        restrict_public_buckets = true
      }
    }
  )

  bucket_sse_configurations = merge(
    {
      default = {
        expected_bucket_owner = null
        bucket_key_enabled = false
        sse_algorithm = "aws:kms"
        kms_master_key_id = null
      }
    },
    var.bucket_sse_configurations
  )

  bucket_versioning_configurations = merge(
    {
      default = {
        expected_bucket_owner = null
        mfa = null
        status = "Disabled"
        mfa_delete = "Disabled"
      }
    },
    var.bucket_versioning_configurations
  )

  bucket_acls = merge(
    {
      default = {
        access_control_policy = null
        acl                   = "private"
        expected_bucket_owner = null
      }
    },
    var.bucket_acls
  )
}
