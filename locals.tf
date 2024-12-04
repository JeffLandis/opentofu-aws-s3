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
        name = "default"
        block_public_acls = true
        ignore_public_acls = true
        block_public_policy = true
        restrict_public_buckets = true
      }
    },
    { for val in var.bucket_pab_configurations: val.name => val }
  )

  bucket_sse_configurations = merge(
    {
      default = {
        name = "default"
        expected_bucket_owner = null
        bucket_key_enabled = false
        sse_algorithm = "aws:kms"
        kms_master_key_id = null
      }
    },
    { for val in var.bucket_sse_configurations: val.name => val }
  )

  bucket_versioning_configurations = merge(
    {
      default = {
        name = "default"
        expected_bucket_owner = null
        mfa = null
        status = "Disabled"
        mfa_delete = "Disabled"
      }
    },
    { for val in var.bucket_versioning_configurations: val.name => val }
  )

  bucket_acls = merge(
    {
      default = {
        name = "default"
        access_control_policy = null
        acl                   = "private"
        expected_bucket_owner = null
      }
    },
    { for val in var.bucket_acls: val.name => val }
  )

  bucket_acl_grants = {
    for grant in var.bucket_acl_grants: grant.name => merge(
      grant,
      { 
        for val in var.bucket_acl_grantees: "grantee" => val 
        if val.name == grant.grantee_name
      }
    )
  }

  bucket_policies = { for val in var.bucket_policies: val.name => val }

}