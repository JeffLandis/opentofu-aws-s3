data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "bucket_policies" {
    for_each = { for k,v in var.bucket_policies: k => v  if v.policy_as_hcl != null }
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
