terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "member6020"
  region = "eu-west-1"
}

locals{
  ami="ami-0b752bf1df193a6c4"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tf-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "vpc_out" {
  value = module.vpc.default_vpc_id
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = local.ami
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = tolist([module.vpc.default_security_group_id])
  subnet_id              = element(module.vpc.public_subnets,0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}