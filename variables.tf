######################################################
# S3 BUCKETS
######################################################
variable "buckets" {
  type = list(object({
    name = optional(string, null)
    prefix = optional(string, null)
    object_ownership = optional(string, "BucketOwnerEnforced")
    tags = optional(map(string), {})
  }))
  default = []
  description = <<-EOT
List of S3 buckets.     
[Bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html). 
| Attribute Name            | Attribute Description                                                                                                                                                             |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                                   | (Optional) Name of the bucket, lowercase and less than 64 characters. Must specify name OR prefix. |
| prefix                                 | (Optional) Creates unique bucket name beginning with prefix, lowercase and less than 38 characters. Must specify name OR prefix. |
| force_destroy                          | (Optional) Whether all objects should be deleted when bucket is destroyed. Default is false.                  |
| object_lock_enabled                    | (Optional) Whether this bucket has Object Lock configuration enabled. Requires Versioning.  Default is false. |
| object_ownership                       | (Optional) Object ownership rule. (BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced) Default is BucketOwnerEnforced.  |
| public_access_block_configuration_name | (Optional) Name of configuration from bucket_public_access_block_configurations. Default name is default, all public access blocked.                  |
| acl_name                               | (Optional) Name of acl from bucket_acls. Default name is default, ACL set as private.                 |
| sse_configuration_name                 | (Optional) Name of server-side encryption configuration from bucket_sse_configurations. Default name is default.
| tags                                   | (Optional) A map of tags to assign to the resource.                                                             |      
EOT
}

######################################################
# S3 BUCKET PUBLIC ACCESS BLOCK CONFIGURATIONS
######################################################
variable "bucket_public_access_block_configurations" {
  type = map(object({
    block_public_acls = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  }))
  default = {}
  description = <<-EOT
Map of S3 bucket Public Access Block configurations. Configuration named **default** with all public access blocked is added to the map by default.        
[Blocking public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
| Attribute Name                            | Attribute Description                                                                                                                                                                        |
|-------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| block_public_acls       | (Optional) Whether public ACLs should be blocked for this bucket. Defaults to true.        |
| ignore_public_acls      | (Optional) Whether public ACLs should be ignored for this bucket. Defaults to true.        |
| block_public_policy     | (Optional) Whether public policies should be blocked for this bucket. Defaults to true.    |
| restrict_public_buckets | (Optional) Whether public policies should be restricted for this bucket. Defaults to true. |
EOT
}

######################################################
# S3 BUCKET SSE CONFIGURATIONS
######################################################
variable "bucket_sse_configurations" {
  type = map(object({
    expected_bucket_owner = optional(string, null)
    rule = optional(object({
      bucket_key_enabled = optional(bool, false)
      apply_server_side_encryption_by_default = optional(object({
        sse_algorithm = optional(string, "aws:kms")
        kms_master_key_id = optional(string, null)
      }), { sse_algorithm = "aws:kms" })
    }), {})
  }))
  default = {}
  description = <<-EOT
Map of S3 bucket server-side encryption configurations. A configuration named **default** using aws:kms with aws/s3 KMS master key is added to the map by default.        
[Server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
| Attribute Name                                   | Attribute Description                                                                                    |
|--------------------------------------------------|----------------------------------------------------------------------------------------------------------|  
| expected_bucket_owner                            | (Optional) Account ID of the expected bucket owner.                                                      |
| rule                                             | (Optional) Server-side encryption configuration rule. Defaults to aws:kms with aws/s3 KMS master key.    |
| &nbsp; - bucket_key_enabled                      | (Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to false.                   |
| &nbsp; - apply_server_side_encryption_by_default | (Optional) Single object for setting server-side encryption by default.                                  |
| &ensp; -- sse_algorithm                          | (Optional) Server-side encryption algorithm to use (AES256, aws:kms, aws:kms:dsse). Defaults to aws:kms. |
| &ensp; -- kms_master_key_id                      | (Optional) AWS KMS master key ID used for the SSE-KMS encryption. Defaults to aws/s3 KMS master key.     |
EOT
}

######################################################
# S3 BUCKET ACLS
######################################################
variable "bucket_acls" {
  type = map(object({
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
  default = { }
  description = <<-EOT
Map of S3 bucket ACLs. An ACL named **default** using private ACL is added to the map by default.           
[Access control list (ACL) overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html)
| Attribute Name         | Attribute Description                                                                                                                                                                        |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| acl                    | (Optional) Canned ACL to apply to the bucket (private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write). |
| expected_bucket_owner  | (Optional) Account ID of the expected bucket owner.                                                                                                                                          |
| access_control_policy  | (Optional) Sets the ACL permissions for an object per grantee. Either access_control_policy or acl is required.                                                                              |
| &nbsp; - grant_name    | (Required) Name from s3_bucket_acl_grants.                                                                                                                                                   |
| &nbsp; - owner         | (Required) Bucket owner's ID and display name.                                                                                                                                               |
| &ensp; -- id           | (Required) ID of the owner.
| &ensp; -- display_name | (Optional) Display name of the owner.
EOT
}

######################################################
# S3 BUCKET ACL GRANTS
######################################################
variable "bucket_acl_grants" {
  type = map(object({
    grantee_name = string
    permission = string  
  }))
  default = {}
  description = <<-EOT
Map of persons being granted permissions.
| Attribute Name| Attribute Description                                                                                           |
|---------------|-----------------------------------------------------------------------------------------------------------------|
| grantee_name  | (Required) Name from s3_bucket_acl_grantees.                                                                    |
| permission    | (Required) Permission to assign to the grantee for the bucket (FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP). |
EOT
}

######################################################
# S3 BUCKET ACL GRANTEES
######################################################
variable "bucket_acl_grantees" {
  type = map(object({
    id = optional(string, null)  
    email_address = optional(string, null)  
    type = string
    uri = optional(string, null)  
  }))
  default = {}
  description = <<-EOT
Map of persons being granted permissions.
| Attribute Name| Attribute Description                                                     |
|---------------|---------------------------------------------------------------------------|
| id            | (Optional) Canonical user ID of the grantee.                              |
| email_address | (Optional) Email address of the grantee.                                  |
| type          | (Required) Type of grantee (CanonicalUser, AmazonCustomerByEmail, Group). |
| uri           | (Optional) URI of the grantee group.                                      |   
EOT
}
