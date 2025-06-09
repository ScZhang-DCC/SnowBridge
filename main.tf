provider "aws" {
  region = var.region
}

##################
# SNS Topic
##################
resource "aws_sns_topic" "alerts" {
  name = "monitoring-alerts"
}

##################
# IAM Roles
##################

# EC2 Role
resource "aws_iam_role" "ec2_monitoring_role" {
  name = "EC2MonitoringRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com.cn"]
    }
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "MonitoringEC2Profile"
  role = aws_iam_role.ec2_monitoring_role.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "EC2SNSTopicPolicy"
  role = aws_iam_role.ec2_monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "FeishuAlertLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com.cn"]
    }
  }
}

resource "aws_iam_policy_attachment" "lambda_basic" {
  name       = "lambda-basic-logs"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws-cn:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##################
# Lambda Functions
##################
resource "aws_lambda_function" "feishu_alert" {
  function_name = "FeishuAlertLambda"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn

  s3_bucket = var.lambda_code_bucket
  s3_key    = var.lambda_code_key

  environment {
    variables = {
      FEISHU_WEBHOOK = var.feishu_webhook
    }
  }

  timeout = 10
}

resource "aws_lambda_function" "jira_ticket" {
  function_name = "JiraTicketLambda"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn

  s3_bucket = var.lambda_code_bucket
  s3_key    = var.jira_lambda_code_key

  environment {
    variables = {
      JIRA_URL     = var.jira_url,
      JIRA_USER    = var.jira_user,
      JIRA_TOKEN   = var.jira_token,
      JIRA_PROJECT = var.jira_project
    }
  }

  timeout = 10
}

resource "aws_sns_topic_subscription" "lambda_feishu_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.feishu_alert.arn
}

resource "aws_sns_topic_subscription" "lambda_jira_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.jira_ticket.arn
}

resource "aws_lambda_permission" "allow_sns_feishu" {
  statement_id  = "AllowExecutionFromSNSFeishu"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.feishu_alert.function_name
  principal     = "sns.amazonaws.com.cn"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_lambda_permission" "allow_sns_jira" {
  statement_id  = "AllowExecutionFromSNSJira"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jira_ticket.function_name
  principal     = "sns.amazonaws.com.cn"
  source_arn    = aws_sns_topic.alerts.arn
}

##################
# EC2 Instances
##################
resource "aws_instance" "cloudprober" {
  ami                    = var.cloudprober_ami
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "CloudProber"
  }
}

resource "aws_instance" "grafana_prometheus" {
  ami                    = var.grafana_prometheus_ami
  instance_type          = "t3.medium"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "GrafanaPrometheus"
  }
}