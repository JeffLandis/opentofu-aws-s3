terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.89"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "pricing"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
        provider-tag = "true"
    }
  }
}

data "aws_canonical_user_id" "current" {}

data "aws_pricing_product" "AmazonS3" {
  provider = aws.pricing
  service_code = "AmazonS3"

  filters {
    field = "regionCode"
    value = var.region
  }

  filters {
    field = "storageClass"
    value = "General Purpose"
  }
}

locals {
  # add a current user grantee
  bucket_acl_grantees = merge(
    {
      current_user = {
          type = "CanonicalUser"
          id   = data.aws_canonical_user_id.current.id
      }
    },
    var.bucket_acl_grantees
  )

  # replace any $${current_canonical_user_id} with current user id
  bucket_acls = { for k,v in var.bucket_acls: k => merge(
    v,
    {
      access_control_policy = (
          lookup(v, "access_control_policy", null) == null
          ? null
          : {
              grant_keys = v.access_control_policy.grant_keys
              owner_id = templatestring(v.access_control_policy.owner_id, {current_canonical_user_id = data.aws_canonical_user_id.current.id})
            }
        )
    })
  }

  storage_pricing_result = try(jsondecode(data.aws_pricing_product.AmazonS3.result).terms.OnDemand, jsondecode(file("${path.module}/default-prices.json")))
  
  storage_pricing = { for k_pt,v_pt in local.storage_pricing_result: v_pt.offerTermCode => {
      effective_date = v_pt.effectiveDate
      prices = { for k_pd,v_pd in v_pt.priceDimensions: v_pd.beginRange =>
        v_pd.description
      }
    }
  }

}

module "s3" {
  source = "../"
  buckets = var.buckets
  bucket_pab_configurations = var.bucket_pab_configurations
  bucket_versioning_configurations = var.bucket_versioning_configurations
  bucket_sse_configurations = var.bucket_sse_configurations
  bucket_acls = local.bucket_acls
  bucket_acl_grants = var.bucket_acl_grants
  bucket_acl_grantees = local.bucket_acl_grantees
  bucket_policies = var.bucket_policies
  tags = var.tags
}
