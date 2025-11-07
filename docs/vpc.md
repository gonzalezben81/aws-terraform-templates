---
title: AWS Terraform VPC Example
vpc_name: example-vpc
public_subnet_cidrs:
  - "10.97.224.64/27"
  - "10.97.224.96/27"
private_subnet_cidrs:
  - "10.97.224.0/27"
  - "10.97.224.32/27"
---

# AWS Terraform VPC Example

Welcome to the AWS Terraform Templates documentation!  
This page demonstrates how to deploy a **VPC with public and private subnets**, an **EC2 instance**, an **Application Load Balancer (ALB)**, **IAM roles**, and an **ACM certificate** using Terraform modules.  

All resources are fully configurable using **page variables** such as `vpc_name` and subnet CIDRs.

---

## Variables

```hcl
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "{{ page.vpc_name }}"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = {{ page.public_subnet_cidrs | jsonify }}
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = {{ page.private_subnet_cidrs | jsonify }}
}
```