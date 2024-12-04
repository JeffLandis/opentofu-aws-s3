######################################################
# S3 BUCKETS
######################################################
variable "buckets" {
  type = list(object({
    name = optional(string, null)
    prefix = optional(string, null)
    force_destroy = optional(bool, false)
    object_lock_enabled = optional(bool, false)
    object_ownership = optional(string, "BucketOwnerEnforced")
    versioning_configuration_name = optional(string, "default")
    pab_configuration_name = optional(string, "default")
    acl_name = optional(string, "default")
    sse_configuration_name = optional(string, "default")
    policy_name = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = []
  nullable = false
  validation {
    condition = alltrue([
      for v in var.buckets : anytrue([
        alltrue([ v.name != null, try(length(v.name), 0) > 0, try(length(v.name), 80) < 64 ]),
        alltrue([ v.prefix != null, try(length(v.prefix), 0) > 0, try(length(v.prefix), 80) < 38 ])
      ])
    ])
    error_message = <<-EOT
A valid bucket 'name' or 'prefix' is required, 'name' has precedence.
Must be lowercase, 'name' less than 64 characters and 'prefix' less than 38 characters.
EOT
  }
  description = <<-EOT
List of S3 buckets. At a minimum, 'name' **or** 'prefix' is required, 'name' has precedence.      
[Bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html). 
| Attribute Name                         | Required?   | Default             | Description                                                                                                           |
|:---------------------------------------|:-----------:|:-------------------:|:----------------------------------------------------------------------------------------------------------------------|
| name                                   | conditional | null                | Name of the bucket, lowercase and less than 64 characters. Must specify name OR prefix.                               |
| prefix                                 | conditional | null                | Creates unique bucket name beginning with prefix, lowercase and less than 38 characters. Must specify name OR prefix. |
| force_destroy                          | optional    | false               | Whether all objects should be deleted when bucket is destroyed.                                                       |
| object_lock_enabled                    | optional    | false               | Whether this bucket has Object Lock configuration enabled. Requires Versioning.                                       |
| object_ownership                       | optional    | BucketOwnerEnforced | Object ownership rule. (BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced)                                      |
| versioning_configuration_name          | optional    | default             | Name of versioning configuration from bucket_versioning_configurations. By default, versioning is disabled.           |
| pab_configuration_name                 | optional    | default             | Name of public access block configuration from bucket_pab_configurations. By default, all public access is blocked.   |
| acl_name                               | optional    | default             | Name of acl from bucket_acls. By default, ACL is set to private.                                                      |
| sse_configuration_name                 | optional    | default             | Name of server side encryption configuration from bucket_sse_configurations. By default, 'aws:kms' with default key.  |
| policy_name                            | optional    | null                | Name of a policy from bucket_policies.                                                                                |
| tags                                   | optional    | { }                 | A map of tags to assign to the resource.                                                                              |      
EOT
}

######################################################
# S3 BUCKET PUBLIC ACCESS BLOCK CONFIGURATIONS
######################################################
variable "bucket_pab_configurations" {
  type = list(object({
    name = string
    block_public_acls = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  }))
  default = []
  description = <<-EOT
List of S3 bucket Public Access Block configurations. Configuration named **default** with all public access blocked is added to the map by default.        
[Blocking public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
| Attribute Name          | Required? | Default | Description                                                                                |
|:------------------------|:---------:|:-------:|:-------------------------------------------------------------------------------------------|
| name                    | required  |         | Unique name to identify configuration, used as pab_configuration_name in buckets variable. |
| block_public_acls       | optional  | true    | Whether public ACLs should be blocked for this bucket.                                     |
| ignore_public_acls      | optional  | true    | Whether public ACLs should be ignored for this bucket.                                     |
| block_public_policy     | optional  | true    | Whether public policies should be blocked for this bucket.                                 |
| restrict_public_buckets | optional  | true    | Whether public policies should be restricted for this bucket.                              |
EOT
}

######################################################
# S3 BUCKET VERSIONING
######################################################
variable "bucket_versioning_configurations" {
  type = list(object({
    name = string
    expected_bucket_owner = optional(string, null)
    mfa = optional(string, null)
    status = optional(string, "Disabled")
    mfa_delete = optional(string, "Disabled")
  }))
  default = []
  description = <<-EOT
List of S3 bucket versioning configurations. Configuration named **default** with versioning disabled is added to the map by default.              
[Versioning on buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/manage-versioning-examples.html)
| Attribute Name           | Required?   | Default  | Description                                                                                                       |
|:-------------------------|:-----------:|:--------:|:------------------------------------------------------------------------------------------------------------------|  
| name                     | required    |          | Unique name to identify configuration, used as versioning_configuration_name in buckets variable.                 |
| expected_bucket_owner    | optional    | null     | Account ID of the expected bucket owner.                                                                          |
| mfa                      | conditional | null     | Authentication device's serial number, space, and value displayed on device. Required if 'mfa_delete' is enabled. |
| status                   | optional    | Disabled | Versioning state of the bucket (Enabled, Suspended).                                                              |
| mfa_delete               | optional    | Disabled | Specifies whether MFA delete is enabled (Enabled, Disabled).                                                      |
EOT
}

######################################################
# S3 BUCKET SSE CONFIGURATIONS
######################################################
variable "bucket_sse_configurations" {
  type = list(object({
    name = string
    expected_bucket_owner = optional(string)
    bucket_key_enabled = optional(bool, false)
    sse_algorithm = optional(string, "aws:kms")
    kms_master_key_id = optional(string)
  }))
  default = []
  description = <<-EOT
List of S3 bucket server side encryption configurations. A configuration named **default** using aws:kms with aws/s3 KMS master key is added to the map by default.        
[Server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
| Attribute Name        | Required? | Default | Description                                                                                     |
|-----------------------|-----------|---------|-------------------------------------------------------------------------------------------------|
| name                  | required  |         | Unique name to identify configuration, used as sse_configuration_name in buckets variable.      |
| expected_bucket_owner | optional  | null    | Account ID of the expected bucket owner.                                                        |
| bucket_key_enabled    | optional  | false   | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to false.                     |
| sse_algorithm         | optional  | aws:kms | Server side encryption algorithm to use (AES256, aws:kms, aws:kms:dsse).                        |
| kms_master_key_id     | optional  | null    | AWS KMS master key ID used for the SSE-KMS encryption. 'aws/s3' KMS master key used by default. |
EOT
}

######################################################
# S3 BUCKET ACLS
######################################################
variable "bucket_acls" {
  type = list(object({
    name = string
    acl = optional(string)
    expected_bucket_owner = optional(string)
    access_control_policy = optional(object({
      grant_names = list(string)
      owner_id = string
      owner_display_name = optional(string)
    }))
  }))
  default = []
  description = <<-EOT
List of S3 bucket ACLs. An 'acl' **or** 'access_control_policy' is required.       
An ACL named **default** using private ACL is added to the map by default.             
[Access control list (ACL) overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html)
| Attribute Name            | Required?   | Default | Description                                                                                                                                                                       |
|---------------------------|-------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                      | required    |         | Unique name to identify the ACL, used as acl_name in buckets variable.                                                                                                            |
| expected_bucket_owner     | optional    | null    | Account ID of the expected bucket owner.                                                                                                                                          |
| acl                       | conditional | null    | Canned ACL to apply to the bucket (private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write). |
| access_control_policy     | conditional | null    | Configuration block for the access control attributes below. Either access_control_policy or acl is required.                                                                     |
| &ensp; grant_names        | conditional |         | List of grant names from bucket_acl_grants. Required for access_control_policy.                                                                                                   |
| &ensp; owner_id           | conditional |         | ID of the owner. Required for access_control_policy.                                                                                                                              |
| &ensp; owner_display_name | optional    | null    | Display name of the owner.                                                                                                                                                        |
EOT
}

######################################################
# S3 BUCKET ACL GRANTS
######################################################
variable "bucket_acl_grants" {
  type = list(object({
    name = string
    grantee_name = string
    permission = optional(string, "READ")
  }))
  default = []
  description = <<-EOT
List of grantees being granted permissions.
| Attribute Name| Required? | Default | Description                                                                                          |
|:--------------|:---------:|:-------:|:-----------------------------------------------------------------------------------------------------|
| name          | required  |         | Unique name to identify the grant, used as grant_names in bucket_acls variable.                      |
| grantee_name  | required  |         | Name of grantee from bucket_acl_grantees.                                                            |
| permission    | optional  | READ    | Permission to assign to the grantee for the bucket (FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP). |
EOT
}

######################################################
# S3 BUCKET ACL GRANTEES
######################################################
variable "bucket_acl_grantees" {
  type = list(object({
    name = string
    type = string
    id = optional(string, null)  
    email_address = optional(string, null)  
    uri = optional(string, null)  
  }))
  default = []
  description = <<-EOT
List of grantees identified by id, email address, or group uri.
| Attribute Name| Required?   | Default | Description                                                                              |
|:--------------|:-----------:|:-------:|:-----------------------------------------------------------------------------------------|
| name          | required    |         | Unique name to identify the grantee, used as grantee_name in bucket_acl_grants variable. |
| type          | required    |         | Type of grantee (CanonicalUser, AmazonCustomerByEmail, Group).                           |
| id            | conditional | null    | Canonical user ID of the grantee. Required for CanonicalUser.                            |
| email_address | conditional | null    | Email address of the grantee. Required for AmazonCustomerByEmail.                        |
| uri           | conditional | null    | URI of the grantee group. Required for Group.                                            | 
EOT
}

######################################################
# S3 BUCKET POLICIES
######################################################
variable "bucket_policies" {
  type = list(object({
    name = string
    policy_as_json = optional(string, null)
    policy_as_hcl = optional(list(object({
        sid = optional(string, null)
        principals = list(object({
          type = string
          identifiers = list(string)
        }))
        not_principals = optional(list(object({
          type = string
          identifiers = list(string) 
        })), null)
        effect = optional(string, "Allow")
        actions = optional(list(string), [])
        not_actions = optional(list(string), [])
        resources = optional(list(string), null)
        not_resources = optional(list(string), null)
        conditions = optional(list(object({
          test = string
          variable = string
          values = list(string) 
        })), [])
    })), null)
  }))
  default = []
  description = <<-EOT
List of bucket policies. The templatestring function will be used on the policy to replace each occurrence of $${bucket_arn} with the bucket's ARN.        
[Bucket policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
| Attribute Name           | Required?   | Default | Description                                                                                                                                                                                       |
|:-------------------------|:-----------:|:-------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                     | required    |         | Unique name to identify the policy, used as policy_name in bucket variable.                                                                                                                       |
| policy_as_json           | conditional | null    | JSON Text of the bucket policy.                                                                                                                                                                   |
| policy_as_hcl            | conditional | null    | List of IAM policy statements. [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement)                            |
| &ensp; sid               | optional    | null    | Sid (statement ID) is an identifier for a policy statement.                                                                                                                                       |
| &ensp; principals        | required    |         | List of principals. [Principal](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html)                                                                      |
| &ensp;&ensp; type        | required    |         | Type of principal (AWS, Service, Federated, CanonicalUser, *).                                                                                                                                    |
| &ensp;&ensp; identifiers | required    |         | List of identifiers applicable for the type of principal.                                                                                                                                         |         
| &ensp; not_principals    | optional    | null    | List of principals. [NotPrincipal](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_notprincipal.html)                                                                |
| &ensp;&ensp; type        | required    |         | Type of principal (AWS, Service, Federated, CanonicalUser, *).                                                                                                                                    |
| &ensp;&ensp; identifiers | required    |         | List of identifiers applicable for the type of principal.                                                                                                                                         |
| &ensp; effect            | optional    | null    | Whether this statement allows or denies the given actions (Allow, Deny). Defaults to Allow.                                                                                                       |
| &ensp; actions           | optional    | null    | List of actions that this statement either allows or denies. [Action](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_action.html)                                   |
| &ensp; not_actions       | optional    | null    | List of actions this statement does not apply to. [NotAction](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_notaction.html)                                        |
| &ensp; resources         | optional    | null    | List of resource ARNs this statement applies to. Conflicts with not_resources.                                                                                                                    |
| &ensp; not_resources     | optional    | null    | List of resource ARNs that this statement does not apply to. Conflicts with resources.                                                                                                            |
| &ensp; conditions        | optional    | null    | List of conditions that determine whether a statement applies in a particular situation. [Condition](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition.html) |                                                                           |
| &ensp;&ensp; test        | required    |         | Name of the IAM condition operator to evaluate.                                                                                                                                                   |
| &ensp;&ensp; variable    | required    |         | Name of a context variable to apply the condition to. May be standard AWS variables starting with aws: or service-specific variables prefixed with the service name.                              |
| &ensp;&ensp; values      | required    |         | Values to evaluate the condition against.                                                                                                                                                         |
EOT
}

######################################################
# TAGS
######################################################
variable "tags" {
  type = map(string)
  nullable = false
  default = {}
  description = "Map of tags to assign to all resources in module"
}
