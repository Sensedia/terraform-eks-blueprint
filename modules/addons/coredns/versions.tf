terraform {
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}
