terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = ">= 5.68"
    }
    random = {
      source = "opentofu/random"
      version = "~> 3.6.3"
    }
  }
}
