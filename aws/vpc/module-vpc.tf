module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = "azure"
  cidr                  = "10.97.224.0/25"
  private_subnet_suffix = "private"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.97.224.0/27", "10.97.224.32/27"]
  public_subnets  = ["10.97.224.64/27", "10.97.224.96/27"]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "azure"
  }
}