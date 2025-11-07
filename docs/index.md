# 🏗️ AWS Terraform Templates
{: .fs-9 }

**Modular Infrastructure as Code for AWS**
{: .fs-6 .fw-300 .text-grey-dk-000 }

---

Welcome to the **AWS Terraform Templates** documentation site — a collection of modular, production-ready Terraform blueprints for building, scaling, and automating AWS environments.

These templates demonstrate real-world, reusable patterns for provisioning AWS infrastructure components such as:

- **🌐 [VPC (Virtual Private Cloud)](vpc.md)** — Secure, highly available networking foundations with public/private subnets, route tables, and NAT gateways.  
- **💻 [EC2 (Elastic Compute Cloud)](ec2.md)** — Configurable compute resources with IAM roles, security groups, and SSM integration.  
- **⚙️ [Lambda (Serverless Compute)](lambda.md)** — Event-driven workloads with environment variables, IAM permissions, and cross-account automation.  
- **🔀 [Transit Gateway (TGW)](tgw.md)** — Centralized connectivity for multi-VPC and multi-region network architectures.

Each module follows **AWS and HashiCorp best practices**, emphasizing clarity, reusability, and security — so you can deploy foundational infrastructure faster and with confidence.

---

## 🚀 Features

- 🧩 Modular Terraform structure for composable deployments  
- 🌎 Multi-account and multi-region support  
- 🔒 IAM least-privilege design principles  
- 📦 Example usage and variable documentation  
- 🧠 Built for learning, automation, and scalability  

---

## 📘 Quick Start

1. Clone this repository  
2. Navigate to a module (e.g., `vpc/`, `lambda/`, `ec2/`, or `tgw/`)  
3. Customize `terraform.tfvars` with your environment values  
4. Deploy your stack:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```