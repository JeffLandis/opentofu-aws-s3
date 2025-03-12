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
    for_each = local.buckets
    bucket = aws_s3_bucket.this[each.key].id
    block_public_acls       = each.value.pab_config.block_public_acls
    block_public_policy     = each.value.pab_config.block_public_policy
    ignore_public_acls      = each.value.pab_config.ignore_public_acls
    restrict_public_buckets = each.value.pab_config.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
    for_each =  local.buckets
    bucket = aws_s3_bucket.this[each.key].id
    rule {
        object_ownership = each.value.object_ownership
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    for_each = local.buckets
    bucket = aws_s3_bucket.this[each.key].id
    expected_bucket_owner = each.value.sse_config.expected_bucket_owner
    rule {
        bucket_key_enabled = each.value.sse_config.bucket_key_enabled
        apply_server_side_encryption_by_default {
            sse_algorithm = each.value.sse_config.sse_algorithm
            kms_master_key_id = each.value.sse_config.kms_master_key_id
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    for_each = local.buckets
    bucket = aws_s3_bucket.this[each.key].id
    expected_bucket_owner = each.value.versioning_config.expected_bucket_owner
    mfa = each.value.versioning_config.mfa
    versioning_configuration {
        status = each.value.versioning_config.status
        mfa_delete = each.value.versioning_config.status != "Disabled" ? each.value.versioning_config.mfa_delete : null
    }
}

resource "aws_s3_bucket_policy" "this" {
    for_each =  { for k,v in local.buckets: k => v.policy if v.policy != null }
    bucket = aws_s3_bucket.this[each.key].id
    policy = (
        each.value.policy_as_hcl == null
        ? templatestring(each.value.policy_as_json, { bucket_arn = aws_s3_bucket.this[each.key].arn })
        : templatestring(data.aws_iam_policy_document.bucket_policies[each.value.name].json, { bucket_arn = aws_s3_bucket.this[each.key].arn })
    )
}

resource "aws_s3_bucket_acl" "this" {
    for_each = {for k,v in local.buckets: k => v.acl if v.object_ownership != "BucketOwnerEnforced" }
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
                for_each = matchkeys(values(local.bucket_acl_grants), keys(local.bucket_acl_grants), access_control_policy.value.grant_keys)
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
    depends_on = [
        aws_s3_bucket_ownership_controls.this,
        aws_s3_bucket_public_access_block.this,
    ]
}
