#Optinal

output "cloudprober_public_ip" {
  value = aws_instance.cloudprober.public_ip
}

output "grafana_prometheus_public_ip" {
  value = aws_instance.grafana_prometheus.public_ip
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.feishu_alert.function_name
}

output "jira_lambda_function_name" {
  value = aws_lambda_function.jira_ticket.function_name
}

# Other resources info