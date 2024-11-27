locals {
    s3_buckets = [
        for val in var.buckets: merge(
            val,
            {
                bucket = (
                    val.name != null
                    ? val.name
                    : join("-",
                    [
                        val.name,
                        replace(var.global.aws_region, "-", ""),
                        var.global.aws_account_id,
                        random_string.s3_bucket_names[val.name].result
                    ])
                )

                
                
                
                

            }
        )
    ]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_string" "s3_bucket_names" {
    for_each = toset([ for val in var.buckets: coalesce(val.name, val.prefix) ])
    length = 5
    special = false
    upper = false
}

resource "aws_s3_bucket" "this" {
    for_each = local.s3_buckets
    bucket = each.value.name
}

resource "aws_s3_bucket_public_access_block" "this" {
    for_each = local.s3_buckets
    bucket = aws_s3_bucket.this[each.key].id
    block_public_acls       = each.value.block_public_acls
    block_public_policy     = each.value.block_public_policy
    ignore_public_acls      = each.value.ignore_public_acls
    restrict_public_buckets = each.value.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
    for_each = local.s3_buckets
    bucket = aws_s3_bucket.this[each.key].id
    rule {
        object_ownership = each.value.object_ownership
    }
}

resource "aws_s3_bucket_acl" "this" {
    for_each = {for k,v in local.s3_buckets: k => v if v.object_ownership != "BucketOwnerEnforced" }
    bucket = aws_s3_bucket.this[each.key].id
    acl    = each.value.acl
    depends_on = [ aws_s3_bucket_ownership_controls.this ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    for_each = local.s3_buckets
    bucket = aws_s3_bucket.this[each.key].id

    rule {
        dynamic "apply_server_side_encryption_by_default" {
            for_each = each.value.sse_kms_master_key_id == null ? [] : [ each.value.sse_kms_master_key_id ]
            content {
                sse_algorithm = each.value.sse_algorithm
                kms_master_key_id = apply_server_side_encryption_by_default.value
            }
        }
        dynamic "apply_server_side_encryption_by_default" {
            for_each = each.value.sse_kms_master_key_id == null ? [ "1" ] : []
            content {
                sse_algorithm = each.value.sse_algorithm
            }
        }
    }
}
