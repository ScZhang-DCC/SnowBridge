variable "region" {
  description = "Region"
  type        = string
  default = "cn-northwest-1" #Replace with your region
}

variable "cloudprober_ami" {
  description = "AMI ID for CloudProber EC2 instance"
  type        = string
}

variable "grafana_prometheus_ami" {
  description = "AMI ID for Grafana/Prometheus EC2 instance"
  type        = string
}

variable "lambda_code_bucket" {
  description = "S3 bucket containing the Lambda zip"
  type        = string
}

variable "lambda_code_key" {
  description = "S3 key path to the Lambda zip"
  type        = string
}

variable "feishu_webhook" {
  description = "Feishu webhook URL"
  type        = string
}

variable "jira_lambda_code_key" {
  description = "S3 key path to the Jira Lambda zip"
  type        = string
}

variable "jira_url" {
  description = "Base URL of the Jira instance"
  type        = string
}

variable "jira_user" {
  description = "Jira username or email"
  type        = string
}

variable "jira_token" {
  description = "Jira API token"
  type        = string
  sensitive   = true
}

variable "jira_project" {
  description = "Jira project key"
  type        = string
}