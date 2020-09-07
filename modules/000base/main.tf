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
