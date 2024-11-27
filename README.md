<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.68)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6.3)

## Providers

The following providers are used by this module:

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.6.3)

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 5.68)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) (resource)
- [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) (resource)
- [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [random_string.s3_bucket_names](https://registry.terraform.io/providers/opentofu/random/latest/docs/resources/string) (resource)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_buckets"></a> [buckets](#input\_buckets)

Description: List of S3 buckets.   
[Bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).
| Attribute Name            | Attribute Description                                                                                                                                                             |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                                   | (Optional) Name of the bucket, lowercase and less than 64 characters. Defaults to a random name. Conflicts with prefix. |
| prefix                                 | (Optional) Creates unique bucket name beginning with prefix, lowercase and less than 38 characters. Conflicts with name.|
| force\_destroy                          | (Optional) Whether all objects should be deleted when bucket is destroyed. Default is false.                  |
| object\_lock\_enabled                    | (Optional) Whether this bucket has Object Lock configuration enabled. Requires Versioning.  Default is false. |
| object\_ownership                       | (Optional) Object ownership rule. (BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced) Defaults to BucketOwnerEnforced.
| public\_access\_block\_configuration\_name | (Optional) Name of configuration from bucket\_public\_access\_block\_configurations.                  |
| acl\_name                               | (Optional) Name of acl from bucket\_acls.                  |
| tags                                   | (Optional) A map of tags to assign to the resource.                                                             |    

Type:

```hcl
list(object({
    name = optional(string, null)
    prefix = optional(string, null)
    object_ownership = optional(string, "BucketOwnerEnforced")
    tags = optional(map(string), {})
  }))
```

Default: `[]`

### <a name="input_bucket_public_access_block_configurations"></a> [bucket\_public\_access\_block\_configurations](#input\_bucket\_public\_access\_block\_configurations)

Description: Map of S3 bucket Public Access Block configurations. Configuration named **default** with all public access blocked is added to the map by default.      
[Blocking public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
| Attribute Name                            | Attribute Description                                                                                                                                                                        |
|-------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| block\_public\_acls       | (Optional) Whether public ACLs should be blocked for this bucket. Defaults to true. |
| ignore\_public\_acls      | (Optional) Whether public ACLs should be ignored for this bucket. Defaults to true. |
| block\_public\_policy     | (Optional) Whether public policies should be blocked for this bucket. Defaults to true. |
| restrict\_public\_buckets | (Optional) Whether public policies should be restricted for this bucket. Defaults to true. |

Type:

```hcl
map(object({
    block_public_acls = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  }))
```

Default: `{}`

### <a name="input_bucket_sse_configurations"></a> [bucket\_sse\_configurations](#input\_bucket\_sse\_configurations)

Description: Map of S3 bucket server-side encryption configurations. A configuration named **default** using aws:kms with aws/s3 KMS master key is added to the map by default.      
[Server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
| Attribute Name                            | Attribute Description                                                                                                                                                                        |
|-------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| expected\_bucket\_owner                     | (Optional) Account ID of the expected bucket owner.                                                      |
| rule                                      | (Optional) Server-side encryption configuration rule. Defaults to aws:kms with aws/s3 KMS master key.    |
| &nbsp; - bucket\_key\_enabled                      | (Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to false.                   |
| &nbsp; - apply\_server\_side\_encryption\_by\_default | (Optional) Single object for setting server-side encryption by default.                                  |
| &ensp; -- sse\_algorithm                          | (Optional) Server-side encryption algorithm to use (AES256, aws:kms, aws:kms:dsse). Defaults to aws:kms. |
| &ensp; -- kms\_master\_key\_id                      | (Optional) AWS KMS master key ID used for the SSE-KMS encryption. Defaults to aws/s3 KMS master key.     |

Type:

```hcl
map(object({
    expected_bucket_owner = optional(string, null)
    rule = optional(object({
      bucket_key_enabled = optional(bool, false)
      apply_server_side_encryption_by_default = optional(object({
        sse_algorithm = optional(string, "aws:kms")
        kms_master_key_id = optional(string, null)
      }), { sse_algorithm = "aws:kms" })
    }), {})
  }))
```

Default: `{}`

### <a name="input_bucket_acls"></a> [bucket\_acls](#input\_bucket\_acls)

Description: Map of S3 bucket ACLs. An ACL named **default** using private ACL is added to the map by default.         
[Access control list (ACL) overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html)
| Attribute Name        | Attribute Description                                                                                                                                                                        |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| acl                   | (Optional) Canned ACL to apply to the bucket (private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write). |
| expected\_bucket\_owner | (Optional) Account ID of the expected bucket owner.                                                                                                                                          |
| access\_control\_policy | (Optional) Sets the ACL permissions for an object per grantee. Either access\_control\_policy or acl is required.                                                                              |
| &nbsp; - grant\_name   | (Required) Name from s3\_bucket\_acl\_grants.                                                                                                                                                   |
| &nbsp; - owner        | (Required) Bucket owner's ID and display name.                                                                                                                                               |
| &ensp; -- id               | (Required) ID of the owner.
| &ensp; -- display\_name     | (Optional) Display name of the owner.

Type:

```hcl
map(object({
    acl = optional(string, "private")
    expected_bucket_owner = optional(string, null)
    access_control_policy = optional(object({
      grant_name = string
      owner = object({
        id = string
        display_name = optional(string, null)
      })
    }), null)
  }))
```

Default: `{}`

### <a name="input_bucket_acl_grants"></a> [bucket\_acl\_grants](#input\_bucket\_acl\_grants)

Description: Map of persons being granted permissions.
| Attribute Name| Attribute Description                                                                                           |
|---------------|-----------------------------------------------------------------------------------------------------------------|
| grantee\_name  | (Required) Name from s3\_bucket\_acl\_grantees.                                                                    |
| permission    | (Required) Permission to assign to the grantee for the bucket (FULL\_CONTROL, WRITE, WRITE\_ACP, READ, READ\_ACP). |

Type:

```hcl
map(object({
    grantee_name = string
    permission = string  
  }))
```

Default: `{}`

### <a name="input_bucket_acl_grantees"></a> [bucket\_acl\_grantees](#input\_bucket\_acl\_grantees)

Description: Map of persons being granted permissions.
| Attribute Name| Attribute Description                                                     |
|---------------|---------------------------------------------------------------------------|
| id            | (Optional) Canonical user ID of the grantee.                              |
| email\_address | (Optional) Email address of the grantee.                                  |
| type          | (Required) Type of grantee (CanonicalUser, AmazonCustomerByEmail, Group). |
| uri           | (Optional) URI of the grantee group.                                      |   

Type:

```hcl
map(object({
    id = optional(string, null)  
    email_address = optional(string, null)  
    type = string
    uri = optional(string, null)  
  }))
```

Default: `{}`

## Outputs

No outputs.
<!-- END_TF_DOCS -->