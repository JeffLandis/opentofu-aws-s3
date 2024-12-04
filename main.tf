data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "bucket_policies" {
    for_each = { for k,v in local.bucket_policies: k => v  if v.policy_as_hcl != null }
    dynamic "statement" {
      for_each = each.value.policy_as_hcl
      content {
        sid = statement.value.sid
        dynamic "principals" {
            for_each = statement.value.principals
            content {
                type = principals.value.type
                identifiers = principals.value.identifiers
            }
        }
        effect = statement.value.effect
        actions = statement.value.actions
        not_actions = statement.value.not_actions
        resources = statement.value.resources
        not_resources = statement.value.not_resources
        dynamic "condition" {
            for_each = statement.value.conditions
            content {
                test = condition.value.test
                variable = condition.value.variable
                values = condition.value.values 
            }
        }
      }
    }
}

resource "random_string" "bucket_name_suffixes" {
    for_each = toset([ for val in var.buckets: val.prefix if val.prefix != null ])
    length = 5
    special = false
    upper = false
}

resource "aws_s3_bucket" "this" {
    for_each = local.buckets
    bucket = each.value.bucket
    force_destroy = each.value.force_destroy
    object_lock_enabled = each.value.object_lock_enabled
    tags = merge(var.tags, { Name = each.value.bucket }, each.value.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
    for_each = { for k,v in local.buckets: k => local.bucket_pab_configurations[v.pab_configuration_name] }
    bucket = aws_s3_bucket.this[each.key].id
    block_public_acls       = each.value.block_public_acls
    block_public_policy     = each.value.block_public_policy
    ignore_public_acls      = each.value.ignore_public_acls
    restrict_public_buckets = each.value.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
    for_each =  local.buckets
    bucket = aws_s3_bucket.this[each.key].id
    rule {
        object_ownership = each.value.object_ownership
    }
}

resource "aws_s3_bucket_acl" "this" {
    for_each = {for k,v in local.buckets: k => local.bucket_acls[v.acl_name] if v.object_ownership != "BucketOwnerEnforced" }
    bucket = aws_s3_bucket.this[each.key].id
    expected_bucket_owner = each.value.expected_bucket_owner
    acl = each.value.acl
    dynamic "access_control_policy" {
        for_each = each.value.acl == null ? [each.value.access_control_policy] : []
        content {   
            owner {
                id = access_control_policy.value.owner_id
                display_name = access_control_policy.value.owner_display_name
            }
            dynamic "grant" {
                for_each = [ for val in access_control_policy.value["grant_names"]: local.bucket_acl_grants[val] ] 
                content {
                    permission = grant.value.permission
                    grantee {
                        type = grant.value.grantee.type
                        id = grant.value.grantee.id
                        email_address = grant.value.grantee.email_address
                        uri = grant.value.grantee.uri 
                    }
                }
            }
        }
    }
    depends_on = [ aws_s3_bucket_ownership_controls.this ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    for_each = { for k,v in local.buckets: k => local.bucket_sse_configurations[v.sse_configuration_name] }
    bucket = aws_s3_bucket.this[each.key].id
    expected_bucket_owner = each.value.expected_bucket_owner
    rule {
        bucket_key_enabled = each.value.bucket_key_enabled
        apply_server_side_encryption_by_default {
            sse_algorithm = each.value.sse_algorithm
            kms_master_key_id = each.value.kms_master_key_id
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    for_each = { for k,v in local.buckets: k => local.bucket_versioning_configurations[v.versioning_configuration_name] }
    bucket = aws_s3_bucket.this[each.key].id
    expected_bucket_owner = each.value.expected_bucket_owner
    mfa = each.value.mfa
    versioning_configuration {
        status = each.value.status
        mfa_delete = each.value.status != "Disabled" ? each.value.mfa_delete : null
    }
}

resource "aws_s3_bucket_policy" "this" {
    for_each =  { for k,v in local.buckets: k => local.bucket_policies[v.policy_name] if v.policy_name != null }
    bucket = aws_s3_bucket.this[each.key].id
    policy = (
        each.value.policy_as_hcl == null
        ? templatestring(each.value.policy_as_json, { bucket_arn = aws_s3_bucket.this[each.key].arn })
        : templatestring(data.aws_iam_policy_document.bucket_policies[each.value.name].json, { bucket_arn = aws_s3_bucket.this[each.key].arn })
    )
}
