
```json
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "example-vpc"
}

#variable "public_subnet_cidrs" {
#  type        = list(string)
#  description = "Public Subnet CIDR values"
#  default     = ["10.97.224.64/27", "10.97.224.96/27"]
#}
#
#variable "private_subnet_cidrs" {
#  type        = list(string)
#  description = "Private Subnet CIDR values"
#  default     = ["10.97.224.0/27", "10.97.224.32/27"]
#}

resource "aws_acm_certificate" "cert" {
  domain_name               = "dsegonzo.us"
  validation_method         = "EMAIL"
  subject_alternative_names = ["*.dsegonzo.us"]

  validation_option {
    domain_name       = "dsegonzo.us"
    validation_domain = "dsegonzo.us"
  }
}

resource "aws_security_group" "loadbalancer" {
  name        = "loadbalancer"
  description = "Allow  inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH"
  }
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"
  ###Type of Load Balancer to create.
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = tolist([module.vpc.public_subnets[0], module.vpc.public_subnets[1]])
  security_groups = tolist([aws_security_group.loadbalancer.id])

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = module.ec2_instance.id
          port      = 80
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.cert.arn
      target_group_index = 0
    }
  ]



  tags = {
    Environment = "Test"
  }
}


# Weighted Forward action

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = module.alb.https_listener_arns
  priority     = 99

  action {
    type = "forward"
    forward {
      target_group {
        arn    = module.alb.target_group_arns
        weight = 80
      }

      target_group {
        arn    = module.alb.target_group_arns
        weight = 20
      }

      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }

  condition {
    host_header {
      values = ["www.dsegonzo.us"]
    }
  }
}


module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "terraform-creation"
  create_private_key = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = var.vpc_name
  cidr                  = "10.97.224.0/25"
  private_subnet_suffix = "private"
  azs                   = ["us-east-1a", "us-east-1b"]
  private_subnets       = ["10.97.224.0/27", "10.97.224.32/27"]
  public_subnets        = ["10.97.224.64/27", "10.97.224.96/27"]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = tomap({ private_subnets = join("-", ["var.vpc_name", "PrivateSubnet"]) })
  public_subnet_tags  = tomap({ public_subnets = join("-", ["var.vpc_name", "PublicSubnet"]) })


}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH"
  }
}



resource "aws_iam_role" "terraform-role" {
  name = "terraform-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]

  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.terraform-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "terraform_instance_profile" {
  name = "terraform-role"
  role = aws_iam_role.terraform-role.name
  path = "/"
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.vpc_name
  ###ec2 image id
  ami                  = "ami-0481e8ba7f486bd99"
  iam_instance_profile = aws_iam_instance_profile.terraform_instance_profile.name
  instance_type        = "t3.micro"
  key_name             = "terraform-creation"
  monitoring           = true
  ###Enable public ip addreess
  associate_public_ip_address = false
  # Use tolist([]) to send a list in terraform
  vpc_security_group_ids = tolist([aws_security_group.ssh.id])
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "private_key" {
  value     = module.key_pair.private_key_pem
  sensitive = true
}
```