<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.68)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6.3)

## Providers

The following providers are used by this module:

- <a name="provider_random"></a> [random](#provider\_random) (3.6.3)

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.78.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) (resource)
- [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) (resource)
- [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) (resource)
- [random_string.bucket_name_suffixes](https://registry.terraform.io/providers/opentofu/random/latest/docs/resources/string) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_buckets"></a> [buckets](#input\_buckets)

Description: List of S3 buckets. At a minimum, 'name' **or** 'prefix' is required, 'name' has precedence.    
[Bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).
| Attribute Name                         | Required?   | Default             | Description                                                                                                           |
|:---------------------------------------|:-----------:|:-------------------:|:----------------------------------------------------------------------------------------------------------------------|
| name                                   | conditional | null                | Name of the bucket, lowercase and less than 64 characters. Must specify name OR prefix.                               |
| prefix                                 | conditional | null                | Creates unique bucket name beginning with prefix, lowercase and less than 38 characters. Must specify name OR prefix. |
| force\_destroy                          | optional    | false               | Whether all objects should be deleted when bucket is destroyed.                                                       |
| object\_lock\_enabled                    | optional    | false               | Whether this bucket has Object Lock configuration enabled. Requires Versioning.                                       |
| object\_ownership                       | optional    | BucketOwnerEnforced | Object ownership rule. (BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced)                                      |
| versioning\_configuration\_name          | optional    | default             | Name of versioning configuration from bucket\_versioning\_configurations. By default, versioning is disabled.           |
| pab\_configuration\_name                 | optional    | default             | Name of public access block configuration from bucket\_pab\_configurations. By default, all public access is blocked.   |
| acl\_name                               | optional    | default             | Name of acl from bucket\_acls. By default, ACL is set to private.                                                      |
| sse\_configuration\_name                 | optional    | default             | Name of server side encryption configuration from bucket\_sse\_configurations. By default, 'aws:kms' with default key.  |
| tags                                   | optional    | { }                 | A map of tags to assign to the resource.                                                                              |    

Type:

```hcl
list(object({
    name = optional(string, null)
    prefix = optional(string, null)
    force_destroy = optional(bool, false)
    object_lock_enabled = optional(bool, false)
    object_ownership = optional(string, "BucketOwnerEnforced")
    versioning_configuration_name = optional(string, "default")
    pab_configuration_name = optional(string, "default")
    acl_name = optional(string, "default")
    sse_configuration_name = optional(string, "default")
    tags = optional(map(string), {})
  }))
```

Default: `[]`

### <a name="input_bucket_pab_configurations"></a> [bucket\_pab\_configurations](#input\_bucket\_pab\_configurations)

Description: Map of S3 bucket Public Access Block configurations. Configuration named **default** with all public access blocked is added to the map by default.      
[Blocking public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
| Attribute Name          | Required? | Default | Description                                                   |
|:------------------------|:---------:|:-------:|:--------------------------------------------------------------|  
| block\_public\_acls       | optional  | true    | Whether public ACLs should be blocked for this bucket.        |
| ignore\_public\_acls      | optional  | true    | Whether public ACLs should be ignored for this bucket.        |
| block\_public\_policy     | optional  | true    | Whether public policies should be blocked for this bucket.    |
| restrict\_public\_buckets | optional  | true    | Whether public policies should be restricted for this bucket. |

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

### <a name="input_bucket_versioning_configurations"></a> [bucket\_versioning\_configurations](#input\_bucket\_versioning\_configurations)

Description: Map of S3 bucket versioning configurations. Configuration named **default** with versioning disabled is added to the map by default.            
[Versioning on buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/manage-versioning-examples.html)
| Attribute Name           | Required?   | Default  | Description                                                                                                                                  |
|:-------------------------|:-----------:|:--------:|:---------------------------------------------------------------------------------------------------------------------------------------------|  
| expected\_bucket\_owner    | optional    | null     | Account ID of the expected bucket owner.                                                                                                     |
| mfa                      | conditional | null     | Authentication device's serial number, space, and value displayed on device. Required if 'mfa\_delete' is enabled. |
| status                   | optional    | Disabled | Versioning state of the bucket (Enabled, Suspended).                                                                               |
| mfa\_delete               | optional    | Disabled | Specifies whether MFA delete is enabled (Enabled, Disabled).                                                                                 |

Type:

```hcl
map(object({
    expected_bucket_owner = optional(string, null)
    mfa = optional(string, null)
    status = optional(string, "Disabled")
    mfa_delete = optional(string, "Disabled")
  }))
```

Default: `{}`

### <a name="input_bucket_sse_configurations"></a> [bucket\_sse\_configurations](#input\_bucket\_sse\_configurations)

Description: Map of S3 bucket server side encryption configurations. A configuration named **default** using aws:kms with aws/s3 KMS master key is added to the map by default.      
[Server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
| Attribute Name        | Required? | Default | Description                                                                                     |
|-----------------------|-----------|---------|-------------------------------------------------------------------------------------------------|  
| expected\_bucket\_owner | optional  | null    | Account ID of the expected bucket owner.                                                        |
| bucket\_key\_enabled    | optional  | false   | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to false.                     |
| sse\_algorithm         | optional  | aws:kms | Server-side encryption algorithm to use (AES256, aws:kms, aws:kms:dsse).                        |
| kms\_master\_key\_id     | optional  | null    | AWS KMS master key ID used for the SSE-KMS encryption. 'aws/s3' KMS master key used by default. |

Type:

```hcl
map(object({
    expected_bucket_owner = optional(string)
    bucket_key_enabled = optional(bool, false)
    sse_algorithm = optional(string, "aws:kms")
    kms_master_key_id = optional(string)
  }))
```

Default: `{}`

### <a name="input_bucket_acls"></a> [bucket\_acls](#input\_bucket\_acls)

Description: Map of S3 bucket ACLs. An 'acl' **or** 'access\_control\_policy' is required.       
An ACL named **default** using private ACL is added to the map by default.           
[Access control list (ACL) overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html)
| Attribute Name            | Required?   | Default | Description                                                                                                                                                                       |
|---------------------------|-------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| expected\_bucket\_owner     | optional    | null    | Account ID of the expected bucket owner.                                                                                                                                          |
| acl                       | conditional | null    | Canned ACL to apply to the bucket (private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write). |
| access\_control\_policy     | conditional | null    | Configuration block for the access control attributes below. Either access\_control\_policy or acl is required.                                                                     |
| &ensp; grant\_names        | conditional |         | List of grant names from bucket\_acl\_grants. Required for access\_control\_policy.                                                                                                   |
| &ensp; owner\_id           | conditional |         | ID of the owner. Required for access\_control\_policy.                                                                                                                              |
| &ensp; owner\_display\_name | optional    | null    | Display name of the owner.                                                                                                                                                        |

Type:

```hcl
map(object({
    acl = optional(string)
    expected_bucket_owner = optional(string)
    access_control_policy = optional(object({
      grant_names = list(string)
      owner_id = string
      owner_display_name = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_bucket_acl_grants"></a> [bucket\_acl\_grants](#input\_bucket\_acl\_grants)

Description: Map of persons being granted permissions.
| Attribute Name| Required? | Default | Description                                                                                          |
|:--------------|:---------:|:-------:|:-----------------------------------------------------------------------------------------------------|
| grantee\_name  | required  |         | Name of grantee from bucket\_acl\_grantees.                                                            |
| permission    | optional  | READ    | Permission to assign to the grantee for the bucket (FULL\_CONTROL, WRITE, WRITE\_ACP, READ, READ\_ACP). |

Type:

```hcl
map(object({
    grantee_name = string
    permission = optional(string, "READ")
  }))
```

Default: `{}`

### <a name="input_bucket_acl_grantees"></a> [bucket\_acl\_grantees](#input\_bucket\_acl\_grantees)

Description: Map of persons being granted permissions.
| Attribute Name| Required?   | Default | Description                                                       |
|:--------------|:-----------:|:-------:|:------------------------------------------------------------------|
| type          | required    |         | Type of grantee (CanonicalUser, AmazonCustomerByEmail, Group).    |
| id            | conditional | null    | Canonical user ID of the grantee. Required for CanonicalUser.     |
| email\_address | conditional | null    | Email address of the grantee. Required for AmazonCustomerByEmail. |
| uri           | conditional | null    | URI of the grantee group. Required for Group.                     |

Type:

```hcl
map(object({
    type = string
    id = optional(string, null)  
    email_address = optional(string, null)  
    uri = optional(string, null)  
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Map of tags to assign to all resources in module

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_caller_identity"></a> [caller\_identity](#output\_caller\_identity)

Description: n/a

### <a name="output_region"></a> [region](#output\_region)

Description: n/a

### <a name="output_buckets"></a> [buckets](#output\_buckets)

Description: n/a

### <a name="output_bucket_pab_configurations"></a> [bucket\_pab\_configurations](#output\_bucket\_pab\_configurations)

Description: n/a

### <a name="output_bucket_ownership_controls"></a> [bucket\_ownership\_controls](#output\_bucket\_ownership\_controls)

Description: n/a

### <a name="output_bucket_acls"></a> [bucket\_acls](#output\_bucket\_acls)

Description: n/a

### <a name="output_bucket_sse_configurations"></a> [bucket\_sse\_configurations](#output\_bucket\_sse\_configurations)

Description: n/a

### <a name="output_bucket_versioning_configurations"></a> [bucket\_versioning\_configurations](#output\_bucket\_versioning\_configurations)

Description: n/a
<!-- END_TF_DOCS -->