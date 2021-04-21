terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.12.1"

  name = "${var.environment}-${var.app_name}-sns-topic"
}

data "null_data_source" "vpn" {
  count = var.number_vpn_connections
  inputs = {
    VpnId = element(var.vpn_connections_ids, count.index)
  }
}

module "vpn_status" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.2"

  alarm_count              = var.number_vpn_connections
  alarm_description        = "${var.app_name}-VPN Connection State"
  alarm_name               = "${var.app_name}-VPN-Status"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.vpn.*.outputs
  evaluation_periods       = var.alarm_evaluations_vpn
  metric_name              = "TunnelState"
  namespace                = "AWS/VPN"
  notification_topic       = [module.sns.topic_arn]
  period                   = var.alarm_period_vpn
  rackspace_alarms_enabled = false
  statistic                = "Maximum"
  threshold                = 0
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

  iam_role_arn = aws_iam_role.backup_service[0].arn
  name         = "${var.environment}-${var.app_name}-backup-selection"
  plan_id      = aws_backup_plan.backup_plan[0].id

  selection_tag {
    key   = var.backup_tag_key
    value = var.backup_tag_value
    type  = "STRINGEQUALS"
  }

}
