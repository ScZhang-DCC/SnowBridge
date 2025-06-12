# Automated Alerting & Ticket Logging System for Snowflake

This project uses Terraform to provision a monitoring infrastructure in the AWS China region (`cn-northwest-1`). It includes:

- Two EC2 instances (CloudProber and Grafana/Prometheus)
- An SNS topic for alerting
- Two Lambda functions:
  - Feishu alert forwarding
  - Jira ticket creation
- IAM roles and policies
- All configurations are region-compliant with AWS China.

## 🛠️ Components

| Component            | Description                                 |
|---------------------|---------------------------------------------|
| EC2 (CloudProber)   | Sends periodic probes to monitor services   |
| EC2 (Grafana/Prom)  | Hosts Grafana dashboards and Prometheus     |
| SNS Topic           | Sends alert notifications                   |
| Lambda: Feishu      | Sends alerts to a Feishu webhook            |
| Lambda: Jira        | Automatically creates Jira issues on alerts |
| IAM Roles/Policies  | Required permissions for EC2 and Lambda     |

## 📦 Files

- `main.tf`: Core infrastructure resources
- `variables.tf`: Input variable definitions
- `terraform.tfvars`: Variable values (fill with your data)
- `outputs.tf`: Useful Terraform outputs
- `README.md`: Project overview and setup guide

## ✅ Prerequisites

- AWS CLI and credentials configured for AWS China
- Terraform >= 1.0.0
- A bucket in S3 (China region) for storing Lambda code zips
- Jira API credentials
- Feishu webhook URL

## 📋 Setup

1. **Edit `terraform.tfvars`** to provide values like:
   - AMI IDs
   - Lambda zip paths
   - Webhook/credentials

2. **Initialize Terraform:**

   ```bash
   terraform init
