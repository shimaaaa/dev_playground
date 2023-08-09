terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.11"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

module "dev" {
  source         = "../modules"
  service_prefix = "playground"
  env            = "dev"

  vpc_cidr = "10.1.0.0/16"
  public_subnets = {
    pub_1c = {
      name = "public-1c"
      cidr = "10.1.10.0/24"
      az   = "ap-northeast-1c"
    },
    pub_1d = {
      name = "public-1d"
      cidr = "10.1.20.0/24"
      az   = "ap-northeast-1d"
    },
  }
  private_subnets = {
    pub_1c = {
      name = "private-1c"
      cidr = "10.1.110.0/24"
      az   = "ap-northeast-1c"
    },
    pub_1d = {
      name = "private-1d"
      cidr = "10.1.120.0/24"
      az   = "ap-northeast-1d"
    },
  }
  ecs_api_tag   = "v0.0.2"
  ecs_api_count = 1
}
