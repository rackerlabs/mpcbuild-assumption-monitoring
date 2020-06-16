output "sns_topic" {
  description = "SNS ARN for monitoring"
  value       = module.sns.topic_arn
}
