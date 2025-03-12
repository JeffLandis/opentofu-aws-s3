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
        pab_config = val.pab_configuration_key != null ? lookup(local.bucket_pab_configurations, val.pab_configuration_key, null) : null
        sse_config = val.sse_configuration_key != null ? lookup(local.bucket_sse_configurations, val.sse_configuration_key, null) : null
        versioning_config = val.versioning_configuration_key != null ? lookup(local.bucket_versioning_configurations, val.versioning_configuration_key, null) : null
        acl = val.acl_key != null ? lookup(local.bucket_acls, val.acl_key, null) : null
        policy = val.policy_key != null ? lookup(var.bucket_policies, val.policy_key, null) : null
      }
    )
  }

  bucket_pab_configurations = merge(
    {
      default = var.defaults.pab_configuration
    },
    var.bucket_pab_configurations
  )

  bucket_sse_configurations = merge(
    {
      default = var.defaults.sse_configuration
    },
    var.bucket_sse_configurations
  )

  bucket_versioning_configurations = merge(
    {
      default = var.defaults.versioning_configuration
    },
    var.bucket_versioning_configurations
  )

  bucket_acls = merge(
    {
      default = var.defaults.acl
    },
    var.bucket_acls
  )

  bucket_acl_grants = {
    for k,v in var.bucket_acl_grants: k => merge(
      v,
      { 
        grantee = lookup(var.bucket_acl_grantees, v.grantee_key, null)
      }
    )
  }

}