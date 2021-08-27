terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

locals {
  rackspace_alarm_config = var.elb_rackspace_alarms_enabled ? "enabled" : "disabled"

  rackspace_alarm_actions = {
    enabled  = [local.rackspace_sns_topic[var.severity]]
    disabled = []
  }
  rackspace_sns_topic = {
    standard  = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-standard"
    urgent    = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-urgent"
    emergency = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency"
  }
}

##### Placeholder for services #####

data "null_data_source" "ec2_instances" {
  count = var.number_ec2_instances
  inputs = {
    InstanceId = element(var.ec2_instance_ids, count.index)
  }
}

data "null_data_source" "asg" {
  count = var.number_asg
  inputs = {
    AutoScalingGroupName = element(var.asg_names, count.index)
  }
}

data "null_data_source" "alb_tg" {
  count = var.number_alb_tg
  inputs = {
    LoadBalancer = lookup(var.alb_tg_list[count.index], "alb_prefix")
    TargetGroup  = lookup(var.alb_tg_list[count.index], "tg_prefix")
  }
}

data "null_data_source" "nlb_tg" {
  count = var.number_nlb_tg
  inputs = {
    LoadBalancer = lookup(var.nlb_tg_list[count.index], "nlb_prefix")
    TargetGroup  = lookup(var.nlb_tg_list[count.index], "tg_prefix")
  }
}

data "null_data_source" "ecs_cluster_service" {
  count = var.number_ecs_services
  inputs = {
    ClusterName = lookup(var.ecs_services_list[count.index], "cluster")
    ServiceName = lookup(var.ecs_services_list[count.index], "service")
  }
}

data "null_data_source" "lambda" {
  count = var.number_lambda_functions
  inputs = {
    FunctionName = element(var.lambda_names, count.index)
  }
}

data "null_data_source" "cloudfront" {
  count = var.number_cloudfront_distributions
  inputs = {
    DistributionId = element(var.cloudfront_distribution_ids, count.index)
    Region         = "Global"
  }
}

data "null_data_source" "api_gw" {
  count = var.number_api_gws
  inputs = {
    ApiName = element(var.api_gw_names, count.index)
  }
}

data "null_data_source" "ec2_memory_windows" {
  count = var.number_win_mem
  inputs = {
    InstanceId = lookup(var.win_mem_list[count.index], "id")
    objectname = "Memory"
  }
}

data "null_data_source" "ec2_disk_windows" {
  count = var.number_win_disk
  inputs = {
    InstanceId = lookup(var.win_disk_list[count.index], "id")
    instance   = lookup(var.win_disk_list[count.index], "disk")
    objectname = "LogicalDisk"
  }
}

data "null_data_source" "ec2_memory_linux" {
  count = var.number_lin_mem
  inputs = {
    InstanceId = element(var.lin_mem_list, count.index)
  }
}

data "null_data_source" "ec2_disk_linux" {
  count = var.number_lin_disk
  inputs = {
    InstanceId = lookup(var.lin_disk_list[count.index], "id")
    device     = lookup(var.lin_disk_list[count.index], "disk")
  }
}

##### EC2 Monitoring #####

module "ec2_status_check_failed_system_alarm_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count       = var.number_ec2_instances
  alarm_description = "Status checks have failed for system, generating ticket."
  alarm_name = join(
    "-",
    ["EC2", "StatusCheckFailedSystemAlarmTicket", var.app_name],
  )
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = data.null_data_source.ec2_instances.*.outputs
  evaluation_periods       = "2"
  notification_topic       = var.notification_topic
  metric_name              = "StatusCheckFailed_System"
  rackspace_alarms_enabled = var.ec2_rackspace_alarms_enabled
  rackspace_managed        = true
  namespace                = "AWS/EC2"
  period                   = "60"
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = "0"
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed_instance_alarm_reboot" {
  count = var.enable_recovery_alarms ? var.number_ec2_instances : 0

  alarm_description = "Status checks have failed, rebooting system."
  alarm_name = join(
    "-",
    [
      "EC2",
      "StatusCheckFailedInstanceAlarmReboot",
      var.app_name,
      count.index + 1,
    ],
  )
  comparison_operator = "GreaterThanThreshold"
  dimensions          = data.null_data_source.ec2_instances[count.index].outputs
  evaluation_periods  = "5"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  unit                = "Count"

  alarm_actions = ["arn:aws:swf:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"]
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed_system_alarm_recover" {
  count = var.enable_recovery_alarms ? var.number_ec2_instances : 0

  alarm_description = "Status checks have failed for system, recovering instance"
  alarm_name = join(
    "-",
    [
      "EC2",
      "StatusCheckFailedSystemAlarmRecover",
      var.app_name,
      count.index + 1,
    ],
  )
  comparison_operator = "GreaterThanThreshold"
  dimensions          = data.null_data_source.ec2_instances[count.index].outputs
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  unit                = "Count"

  alarm_actions = ["arn:aws:automate:${data.aws_region.current_region.name}:ec2:recover"]
}

module "ec2_status_check_failed_instance_alarm_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count       = var.number_ec2_instances
  alarm_description = "Status checks have failed, generating ticket."
  alarm_name = join(
    "-",
    ["EC2", "StatusCheckFailedInstanceAlarmTicket", var.app_name],
  )
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = data.null_data_source.ec2_instances.*.outputs
  evaluation_periods       = "10"
  metric_name              = "StatusCheckFailed_Instance"
  notification_topic       = var.notification_topic
  namespace                = "AWS/EC2"
  period                   = "60"
  rackspace_alarms_enabled = var.ec2_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = "0"
  unit                     = "Count"
}

module "ec2_cpu_alarm_high" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_ec2_instances
  alarm_description        = "CPU Alarm ${var.ec2_cw_cpu_high_operator} ${var.ec2_cw_cpu_high_threshold}% for ${var.ec2_cw_cpu_high_period} seconds ${var.ec2_cw_cpu_high_evaluations} times."
  alarm_name               = join("-", ["EC2", "CPUAlarmHigh", var.app_name])
  comparison_operator      = var.ec2_cw_cpu_high_operator
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.ec2_instances.*.outputs
  evaluation_periods       = var.ec2_cw_cpu_high_evaluations
  metric_name              = "CPUUtilization"
  notification_topic       = var.notification_topic
  namespace                = "AWS/EC2"
  period                   = var.ec2_cw_cpu_high_period
  rackspace_alarms_enabled = false
  rackspace_managed        = true
  statistic                = "Average"
  threshold                = var.ec2_cw_cpu_high_threshold
  unit                     = "Percent"
}

##### EC2 custom monitoring ######

module "ec2_win_disk_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_win_disk
  alarm_description        = "Free disk available is less than ${var.ec2_disk_windows_threshold}"
  alarm_name               = join("-", ["EC2-Windows", "DiskLowAlarm", var.app_name])
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.ec2_disk_windows.*.outputs
  evaluation_periods       = 10
  metric_name              = "LogicalDisk % Free Space"
  notification_topic       = var.notification_topic
  namespace                = var.cw_namespace_windows
  period                   = 60
  rackspace_alarms_enabled = false
  rackspace_managed        = true
  statistic                = "Average"
  threshold                = var.ec2_disk_windows_threshold
  unit                     = "Percent"
}

##### Auto Scaling Group Monitoring #####

module "asg_group_terminating_instances" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_asg
  alarm_description        = "Over ${var.asg_terminated_instances} instances terminated in last 6 hours, generating ticket to investigate."
  alarm_name               = "${var.app_name}-ASG-GroupTerminatingInstances"
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = data.null_data_source.asg.*.outputs
  evaluation_periods       = 1
  metric_name              = "GroupTerminatingInstances"
  namespace                = "AWS/AutoScaling"
  notification_topic       = var.notification_topic
  period                   = 21600
  rackspace_alarms_enabled = var.asg_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Sum"
  threshold                = var.asg_terminated_instances
  unit                     = "Count"
}

##### Elastic Load Balancers & Target Groups Monitoring #####

module "alb_unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.alb_unhealthy_target_threshold == "" ? var.number_alb_tg : 0
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_alb_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.alb_tg.*.outputs
  evaluation_periods       = 10
  metric_name              = "UnHealthyHostCount"
  namespace                = "AWS/ApplicationELB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.elb_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Maximum"
  threshold                = 1
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealth_host_percentage_alarm" {
  count = var.alb_unhealthy_target_threshold != "" ? var.number_alb_tg : 0

  alarm_description   = "Percentage of unhealthy targets is bigger than threshold, creating ticket."
  alarm_name          = var.number_alb_tg > 1 ? format("%v-%03d", "${var.app_name}_alb_unhealthy_percentage_alarm", count.index + 1) : "${var.app_name}_alb_unhealthy_percentage_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.alb_unhealthy_target_threshold

  metric_query {
    id          = "e1"
    expression  = "100*(m1/(m1+m2))"
    label       = "UnHealthyHostPercentange"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "UnHealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Maximum"
      unit        = "Count"
      dimensions  = data.null_data_source.alb_tg[count.index].outputs
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "HealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Maximum"
      unit        = "Count"
      dimensions  = data.null_data_source.alb_tg[count.index].outputs
    }
  }

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions[local.rackspace_alarm_config],
  )
}

module "alb_target_response_time_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.alb_response_time_threshold != "" ? var.number_alb_tg : 0
  alarm_description        = "Target response time is higher than threshold, creating ticket."
  alarm_name               = "${var.app_name}_alb_target_response_time_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.alb_tg.*.outputs
  evaluation_periods       = 10
  metric_name              = "TargetResponseTime"
  namespace                = "AWS/ApplicationELB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.elb_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.alb_response_time_threshold
  unit                     = "Seconds"
}

module "nlb_unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.nlb_unhealthy_target_threshold == "" ? var.number_nlb_tg : 0
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_nlb_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.nlb_tg.*.outputs
  evaluation_periods       = 10
  metric_name              = "UnHealthyHostCount"
  namespace                = "AWS/NetworkELB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.elb_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Maximum"
  threshold                = 1
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "nlb_unhealth_host_percentage_alarm" {
  count = var.nlb_unhealthy_target_threshold != "" ? var.number_nlb_tg : 0

  alarm_description   = "Percentage of unhealthy targets is bigger than threshold, creating ticket."
  alarm_name          = var.number_alb_tg > 1 ? format("%v-%03d", "${var.app_name}_nlb_unhealthy_percentage_alarm", count.index + 1) : "${var.app_name}_alb_unhealthy_percentage_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.nlb_unhealthy_target_threshold

  metric_query {
    id          = "e1"
    expression  = "100*(m1/(m1+m2))"
    label       = "UnHealthyHostPercentange"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "UnHealthyHostCount"
      namespace   = "AWS/NetworkELB"
      period      = "60"
      stat        = "Maximum"
      unit        = "Count"
      dimensions  = data.null_data_source.nlb_tg[count.index].outputs
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "HealthyHostCount"
      namespace   = "AWS/NetworkELB"
      period      = "60"
      stat        = "Maximum"
      unit        = "Count"
      dimensions  = data.null_data_source.nlb_tg[count.index].outputs
    }
  }

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions[local.rackspace_alarm_config],
  )
}

####### ECS monitoring #######

module "ecs_cpu_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_ecs_services
  alarm_description        = "CPU utilization is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_ecs_cpu_utilization_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.ecs_cluster_service.*.outputs
  evaluation_periods       = 5
  metric_name              = "CPUUtilization"
  namespace                = "AWS/ECS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.ecs_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.ecs_cpu_high_threshold
  unit                     = "Percent"
}

module "ecs_memory_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_ecs_services
  alarm_description        = "Memory utilization is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_ecs_memory_utilization_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.ecs_cluster_service.*.outputs
  evaluation_periods       = 5
  metric_name              = "MemoryUtilization"
  namespace                = "AWS/ECS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.ecs_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.ecs_memory_high_threshold
  unit                     = "Percent"
}

####### Lambda monitoring #######

module "lambda_errors_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_lambda_functions
  alarm_description        = "Errors during Lambda execution is greater than threshold, creating ticket."
  alarm_name               = "${var.app_name}_lambda_errors_alarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.lambda.*.outputs
  evaluation_periods       = 1
  metric_name              = "Errors"
  namespace                = "AWS/Lambda"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.lambda_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = "0"
  unit                     = "Count"
}

####### Cloudfront monitoring #######

module "cloudfront_total_errors_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.cloudfront_total_errors_threshold != "" ? var.number_cloudfront_distributions : 0
  alarm_description        = "Percentage of total errors is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_cloudfront_total_errors_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.cloudfront.*.outputs
  evaluation_periods       = 5
  metric_name              = "TotalErrorRate"
  namespace                = "AWS/CloudFront"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.cloudfront_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.cloudfront_total_errors_threshold
  unit                     = "Percent"
}

module "cloudfront_500_errors_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.cloudfront_500_errors_threshold != "" ? var.number_cloudfront_distributions : 0
  alarm_description        = "Percentage of 500 errors is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_cloudfront_500_errors_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.cloudfront.*.outputs
  evaluation_periods       = 5
  metric_name              = "5xxErrorRate"
  namespace                = "AWS/CloudFront"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.cloudfront_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.cloudfront_500_errors_threshold
  unit                     = "Percent"
}

####### API Gateway #######

module "api_gw_500_errors_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.api_gw_500_errors_threshold != "" ? var.number_api_gws : 0
  alarm_description        = "Number of 500 errors is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_api_gw_500_errors_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.api_gw.*.outputs
  evaluation_periods       = 5
  metric_name              = "5XXError"
  namespace                = "AWS/ApiGateway"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.api_gw_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Sum"
  threshold                = var.api_gw_500_errors_threshold
  unit                     = "Count"
}

module "api_gw_400_errors_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.api_gw_400_errors_threshold != "" ? var.number_api_gws : 0
  alarm_description        = "Number of 400 errors is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_api_gw_400_errors_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.api_gw.*.outputs
  evaluation_periods       = 5
  metric_name              = "4XXError"
  namespace                = "AWS/ApiGateway"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.api_gw_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Sum"
  threshold                = var.api_gw_400_errors_threshold
  unit                     = "Count"
}

module "api_gw_latency_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.api_gw_latency_threshold != "" ? var.number_api_gws : 0
  alarm_description        = "Latency is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_api_gw_latency_alarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.api_gw.*.outputs
  evaluation_periods       = 5
  metric_name              = "Latency"
  namespace                = "AWS/ApiGateway"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.api_gw_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = var.api_gw_latency_threshold
  unit                     = "Milliseconds"
}
