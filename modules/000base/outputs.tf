output "sns_topic" {
  description = "SNS ARN for monitoring"
  value       = coalesce(var.existing_sns_topic, module.sns.topic_arn)
}
