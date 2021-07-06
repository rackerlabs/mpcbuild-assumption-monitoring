terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

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

##### Auto Scaling Group Monitoring #####

resource "aws_autoscaling_policy" "ec2_scale_up_policy" {
  count = var.asg_enable_scaling_actions ? var.number_asg : 0

  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = element(var.asg_names, count.index)
  cooldown               = var.asg_ec2_scale_up_cool_down
  name                   = join("-", compact(["ec2_scale_up_policy", var.app_name, format("%03d", count.index + 1)]))
  scaling_adjustment     = var.asg_ec2_scale_up_adjustment
}

resource "aws_autoscaling_policy" "ec2_scale_down_policy" {
  count = var.asg_enable_scaling_actions ? var.number_asg : 0

  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = element(var.asg_names, count.index)
  cooldown               = var.asg_ec2_scale_down_cool_down
  name                   = join("-", compact(["ec2_scale_down_policy", var.app_name, format("%03d", count.index + 1)]))
  scaling_adjustment     = var.asg_ec2_scale_down_adjustment > 0 ? -var.asg_ec2_scale_down_adjustment : var.asg_ec2_scale_down_adjustment
}

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

resource "aws_cloudwatch_metric_alarm" "asg_scale_alarm_high" {
  count = var.asg_enable_scaling_actions ? var.number_asg : 0

  alarm_actions       = [element(aws_autoscaling_policy.ec2_scale_up_policy.*.arn, count.index)]
  alarm_description   = "Scale-up if ${var.asg_cw_scaling_metric} ${var.asg_cw_high_operator} ${var.asg_cw_high_threshold}% for ${var.asg_cw_high_period} seconds ${var.asg_cw_high_evaluations} times."
  alarm_name          = join("-", compact(["ASG-ScaleAlarmHigh", var.app_name, format("%03d", count.index + 1)]))
  comparison_operator = var.asg_cw_high_operator
  evaluation_periods  = var.asg_cw_high_evaluations
  metric_name         = var.asg_cw_scaling_metric
  namespace           = "AWS/EC2"
  period              = var.asg_cw_high_period
  statistic           = "Average"
  threshold           = var.asg_cw_high_threshold
  dimensions          = data.null_data_source.asg[count.index].outputs
}

resource "aws_cloudwatch_metric_alarm" "asg_scale_alarm_low" {
  count = var.asg_enable_scaling_actions ? var.number_asg : 0

  alarm_actions       = [element(aws_autoscaling_policy.ec2_scale_down_policy.*.arn, count.index)]
  alarm_description   = "Scale-down if ${var.asg_cw_scaling_metric} ${var.asg_cw_low_operator} ${var.asg_cw_low_threshold}% for ${var.asg_cw_low_period} seconds ${var.asg_cw_low_evaluations} times."
  alarm_name          = join("-", compact(["ASG-ScaleAlarmLow", var.app_name, format("%03d", count.index + 1)]))
  comparison_operator = var.asg_cw_low_operator
  evaluation_periods  = var.asg_cw_low_evaluations
  metric_name         = var.asg_cw_scaling_metric
  namespace           = "AWS/EC2"
  period              = var.asg_cw_low_period
  statistic           = "Average"
  threshold           = var.asg_cw_low_threshold
  dimensions          = data.null_data_source.asg[count.index].outputs
}

##### Elastic Load Balancers & Target Groups Monitoring #####

module "alb_unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_alb_tg
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_alb_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
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

module "alb_target_response_time_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_alb_tg
  alarm_description        = "Target response time is higher than threshold, creating ticket."
  alarm_name               = "${var.app_name}_alb_target_response_time_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
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

  alarm_count              = var.number_nlb_tg
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_nlb_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
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

####### ECS monitoring #######

module "ecs_cpu_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_ecs_services
  alarm_description        = "CPU utilization is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.app_name}_ecs_cpu_utilization_alarm"
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
