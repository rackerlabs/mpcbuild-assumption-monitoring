terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_caller_identity" "current_account" {}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.12.1"

  name = "${var.app_name}-${var.environment}-monitoring-sns-topic"
}

data "null_data_source" "vpn" {
  count = var.number_vpn_connections
  inputs = {
    VpnId = element(var.vpn_connections_ids, count.index)
  }
}

data "null_data_source" "dx" {
  count = var.number_dx_connections
  inputs = {
    ConnectionId = element(var.dx_connections_ids, count.index)
  }
}

data "null_data_source" "hc" {
  count = var.number_health_checks
  inputs = {
    HealthCheckId = element(var.health_check_ids, count.index)
  }
}

module "vpn_status_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_vpn_connections
  alarm_description        = "${var.app_name}-VPN Connection State"
  alarm_name               = "VPN-StatusAlarm-${var.app_name}"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.vpn.*.outputs
  evaluation_periods       = var.alarm_evaluations_vpn
  metric_name              = "TunnelState"
  namespace                = "AWS/VPN"
  notification_topic       = var.existing_sns_topic != "" ? [var.existing_sns_topic] : [module.sns.topic_arn]
  period                   = var.alarm_period_vpn
  rackspace_alarms_enabled = var.vpn_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.vpn_alarm_severity
  statistic                = "Maximum"
  threshold                = 0
  unit                     = "None"
}

module "dx_status_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_dx_connections
  alarm_description        = "${var.app_name}-DX Connection State"
  alarm_name               = "DX-StatusAlarm-${var.app_name}"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.dx.*.outputs
  evaluation_periods       = 5
  metric_name              = "ConnectionState"
  namespace                = "AWS/DX"
  notification_topic       = var.existing_sns_topic != "" ? [var.existing_sns_topic] : [module.sns.topic_arn]
  period                   = 60
  rackspace_alarms_enabled = var.dx_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.dx_alarm_severity
  statistic                = "Maximum"
  threshold                = 0
  unit                     = "None"
}

module "hc_status_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_health_checks
  alarm_description        = "${var.app_name}-HC status alarm"
  alarm_name               = "Route53-HealthCheckStatusAlarm-${var.app_name}"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.hc.*.outputs
  evaluation_periods       = 5
  metric_name              = "HealthCheckStatus"
  namespace                = "AWS/Route53"
  notification_topic       = var.existing_sns_topic != "" ? [var.existing_sns_topic] : [module.sns.topic_arn]
  period                   = 60
  rackspace_alarms_enabled = var.r53_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.r53_alarm_severity
  statistic                = "Maximum"
  threshold                = 0
  unit                     = "None"
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup_service" {
  count = var.enable_aws_backup && var.create_backup_role ? 1 : 0

  name               = "AWSBackupDefaultServiceRole"
  description        = "Provides AWS Backup permission to create backups and perform restores on your behalf across AWS services."
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  count = var.enable_aws_backup && var.create_backup_role ? 1 : 0

  role       = aws_iam_role.backup_service[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  count = var.enable_aws_backup && var.create_backup_role ? 1 : 0

  role       = aws_iam_role.backup_service[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_vault" "backup_vault" {
  count = var.enable_aws_backup ? 1 : 0

  name = "${var.environment}-${var.app_name}-backup-vault"
}

resource "aws_backup_plan" "backup_plan" {
  count = var.enable_aws_backup ? 1 : 0

  name = "${var.environment}-${var.app_name}-backup-plan"

  rule {
    rule_name         = "${var.environment}-${var.app_name}-backup-plan"
    target_vault_name = aws_backup_vault.backup_vault[0].name

    lifecycle {
      delete_after = var.retention_period_backup
    }

    schedule          = var.schedule_backup
    start_window      = var.start_window_backup
    completion_window = var.completion_window_backup
  }
}

resource "aws_backup_selection" "backup_selection" {
  count = var.enable_aws_backup ? 1 : 0

  iam_role_arn = var.create_backup_role ? aws_iam_role.backup_service[0].arn : "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:role/service-role/AWSBackupDefaultServiceRole"
  name         = "${var.environment}-${var.app_name}-backup-selection"
  plan_id      = aws_backup_plan.backup_plan[0].id

  selection_tag {
    key   = var.backup_tag_key
    value = var.backup_tag_value
    type  = "STRINGEQUALS"
  }

}
