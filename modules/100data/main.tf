terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

locals {
  rackspace_alarm_config_rds    = var.rds_rackspace_alarms_enabled ? "enabled" : "disabled"
  rackspace_alarm_config_aurora = var.aurora_rackspace_alarms_enabled ? "enabled" : "disabled"
  rackspace_alarm_config_efs    = var.efs_rackspace_alarms_enabled ? "enabled" : "disabled"

  rackspace_alarm_actions_rds = {
    enabled  = [local.rackspace_sns_topic[var.rds_alarm_severity]]
    disabled = []
  }
  rackspace_alarm_actions_aurora = {
    enabled  = [local.rackspace_sns_topic[var.aurora_alarm_severity]]
    disabled = []
  }
  rackspace_alarm_actions_efs = {
    enabled  = [local.rackspace_sns_topic[var.efs_alarm_severity]]
    disabled = []
  }
  rackspace_sns_topic = {
    standard  = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-standard"
    urgent    = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-urgent"
    emergency = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency"
  }
  aurora_memory = {
    "optimized_large"    = 16
    "optimized_xlarge"   = 32
    "optimized_2xlarge"  = 64
    "optimized_4xlarge"  = 128
    "optimized_8xlarge"  = 256
    "optimized_12xlarge" = 384
    "optimized_16xlarge" = 512
    "optimized_24xlarge" = 768
    "burstable_large"    = 8
    "burstable_medium"   = 4
    "burstable_small"    = 2
    "legacy_large"       = 15.25
    "legacy_xlarge"      = 30.5
    "legacy_2xlarge"     = 61
    "legacy_4xlarge"     = 122
    "legacy_8xlarge"     = 244
    "legacy_16xlarge"    = 488
  }
}

##### Placeholder for each service #####

# data "null_data_source" "rds_instances" {
#   count = var.number_rds_instances
#   inputs = {
#     DBInstanceIdentifier = element(var.rds_instance_identifiers, count.index)
#   }
# }

data "null_data_source" "rds_instances" {
  count = var.number_rds_instances
  inputs = {
    DBInstanceIdentifier = lookup(var.rds_instances_list[count.index], "id")
  }
}

# data "null_data_source" "rds_read_replicas" {
#   count = var.number_rds_read_replicas
#   inputs = {
#     DBInstanceIdentifier = element(var.read_replicas_identifiers, count.index)
#   }
# }

data "null_data_source" "rds_read_replicas" {
  count = var.number_rds_instances
  inputs = {
    DBInstanceIdentifier = lookup(var.rds_replicas_list[count.index], "id")
  }
}

# data "null_data_source" "aurora_clusters" {
#   count = var.number_aurora_clusters
#   inputs = {
#     DbClusterIdentifier = lookup(var.aurora_clusters[count.index], "cluster_id")
#     EngineName          = lookup(var.aurora_clusters[count.index], "engine")
#   }
# }

data "null_data_source" "aurora_nodes" {
  count = var.number_aurora_nodes
  inputs = {
    DBInstanceIdentifier = lookup(var.aurora_nodes[count.index], "id")
  }
}

data "null_data_source" "aurora_readers" {
  count = var.number_aurora_readers
  inputs = {
    DBInstanceIdentifier = element(var.aurora_readers_identifiers, count.index)
  }
}

data "null_data_source" "efs" {
  count = var.number_elastic_filesystems
  inputs = {
    FileSystemId = element(var.elastic_filesystem_ids, count.index)
  }
}

data "null_data_source" "redshift" {
  count = var.number_redshift_nodes
  inputs = {
    ClusterIdentifier = element(var.redshift_nodes_ids, count.index)
  }
}

data "null_data_source" "redis" {
  count = var.number_redis_clusters
  inputs = {
    CacheClusterId = element(var.redis_cluster_ids, count.index)
  }
}

data "null_data_source" "fsx" {
  count = var.number_fsx_filesystems
  inputs = {
    FileSystemId = element(var.fsx_ids, count.index)
  }
}

data "null_data_source" "dynamodb" {
  count = var.number_dynamo_tables
  inputs = {
    TableName = element(var.dynamo_tables, count.index)
  }
}

##### RDS Monitoring #####

# module "rds_free_storage_space_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_instances
#   alarm_description        = "Free storage space has fallen below threshold, sending email notification."
#   alarm_name               = "${var.app_name}-rds-free-storage-space-email"
#   comparison_operator      = "LessThanOrEqualToThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 30
#   metric_name              = "FreeStorageSpace"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = false
#   statistic                = "Average"
#   threshold                = var.rds_alarm_free_space_limit
#   unit                     = "Bytes"
#   dimensions               = data.null_data_source.rds_instances.*.outputs
# }

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space_alarm" {
  count = var.number_rds_instances

  alarm_description   = "Storage available is less than ${var.rds_alarm_free_space_threshold}%"
  alarm_name          = var.number_rds_instances > 1 ? format("%v-%03d", "${var.app_name}-RDS-FreeStorageAlarm", count.index + 1) : "${var.app_name}-RDS-FreeStorageAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 30
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  period              = 60
  statistic           = "Average"
  unit                = "Bytes"
  threshold           = floor((var.rds_alarm_free_space_threshold * 0.01) * (var.rds_instances_list[count.index]["storage"] * 1073741824))
  dimensions          = data.null_data_source.rds_instances[count.index].outputs

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions_rds[local.rackspace_alarm_config_rds],
  )
  ok_actions = local.rackspace_alarm_actions_rds[local.rackspace_alarm_config_rds]
}

# module "rds_replica_free_storage_space_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_read_replicas
#   alarm_description        = "Free storage space has fallen below threshold, sending email notification."
#   alarm_name               = "${var.app_name}-rds-replica-free-storage-space-email"
#   comparison_operator      = "LessThanOrEqualToThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 30
#   metric_name              = "FreeStorageSpace"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = false
#   statistic                = "Average"
#   threshold                = var.rds_alarm_free_space_limit
#   unit                     = "Bytes"
#   dimensions               = data.null_data_source.rds_read_replicas.*.outputs
# }

resource "aws_cloudwatch_metric_alarm" "rds_replica_free_storage_space_alarm" {
  count = var.number_rds_read_replicas

  alarm_description   = "Storage available is less than ${var.rds_alarm_free_space_threshold}%"
  alarm_name          = var.number_rds_read_replicas > 1 ? format("%v-%03d", "${var.app_name}-RDS-Replica-FreeStorageAlarm", count.index + 1) : "${var.app_name}-RDS-Replica-FreeStorageAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 30
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  period              = 60
  statistic           = "Average"
  unit                = "Bytes"
  threshold           = floor((var.rds_alarm_free_space_threshold * 0.01) * (var.rds_replicas_list[count.index]["storage"] * 1073741824))
  dimensions          = data.null_data_source.rds_read_replicas[count.index].outputs

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions_rds[local.rackspace_alarm_config_rds],
  )
  ok_actions = local.rackspace_alarm_actions_rds[local.rackspace_alarm_config_rds]
}

# module "rds_write_iops_high_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_instances
#   alarm_description        = "Alarm if WriteIOPs > ${var.rds_alarm_write_iops_limit} for 5 minutes"
#   alarm_name               = "${var.app_name}-rds-write-iops-high-email"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 5
#   metric_name              = "WriteIOPS"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.rds_alarm_write_iops_limit
#   unit                     = "Count/Second"
#   dimensions               = data.null_data_source.rds_instances.*.outputs
# }
#
# module "rds_replica_write_iops_high_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_read_replicas
#   alarm_description        = "Alarm if WriteIOPs > ${var.rds_alarm_write_iops_limit} for 5 minutes"
#   alarm_name               = "${var.app_name}-rds-replica-write-iops-high-email"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 5
#   metric_name              = "WriteIOPS"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.rds_alarm_write_iops_limit
#   unit                     = "Count/Second"
#   dimensions               = data.null_data_source.rds_read_replicas.*.outputs
# }
#
# module "rds_read_iops_high_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_instances
#   alarm_description        = "Alarm if ReadIOPs > ${var.rds_alarm_read_iops_limit} for 5 minutes"
#   alarm_name               = "${var.app_name}-rds-read-iops-high-email"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 5
#   metric_name              = "ReadIOPS"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.rds_alarm_read_iops_limit
#   unit                     = "Count/Second"
#   dimensions               = data.null_data_source.rds_instances.*.outputs
# }
#
# module "rds_replica_read_iops_high_alarm_email" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_read_replicas
#   alarm_description        = "Alarm if ReadIOPs > ${var.rds_alarm_read_iops_limit} for 5 minutes"
#   alarm_name               = "${var.app_name}-rds-replica-read-iops-high-email"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 5
#   metric_name              = "ReadIOPS"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.rds_alarm_read_iops_limit
#   unit                     = "Count/Second"
#   dimensions               = data.null_data_source.rds_read_replicas.*.outputs
# }

module "rds_cpu_high_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Alarm if CPU > ${var.rds_alarm_cpu_limit} for 15 minutes"
  alarm_name               = "${var.app_name}-RDS-CPUUtilizationAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "CPUUtilization"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.rds_alarm_severity
  statistic                = "Average"
  threshold                = var.rds_alarm_cpu_limit
  unit                     = "Percent"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_cpu_high_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Alarm if CPU > ${var.rds_alarm_cpu_limit} for 15 minutes"
  alarm_name               = "${var.app_name}-RDS-Replica-CPUUtilizationAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "CPUUtilization"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.rds_alarm_severity
  statistic                = "Average"
  threshold                = var.rds_alarm_cpu_limit
  unit                     = "Percent"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

# module "replica_lag_alarm_ticket" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"
#
#   alarm_count              = var.number_rds_read_replicas
#   alarm_description        = "ReplicaLag has exceeded threshold, generating ticket.."
#   alarm_name               = "RDS-Replica-LagAlarm-${var.app_name}"
#   comparison_operator      = "GreaterThanOrEqualToThreshold"
#   evaluation_periods       = 5
#   metric_name              = "ReplicaLag"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
#   rackspace_managed        = true
#   severity                 = "urgent"
#   statistic                = "Average"
#   threshold                = 3600
#   unit                     = "Seconds"
#   dimensions               = data.null_data_source.rds_read_replicas.*.outputs
# }

module "replica_lag_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "ReplicaLag has exceeded threshold."
  alarm_name               = "${var.app_name}-RDS-Replica-LagAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 3
  metric_name              = "ReplicaLag"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.rds_alarm_severity
  statistic                = "Average"
  threshold                = var.rds_replica_lag_threshold
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_depth_queue_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_depth_queue_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if Depth queue is > ${var.rds_depth_queue_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-RDS-DepthQueueAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "DiskQueueDepth"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.rds_alarm_severity
  statistic                = "Average"
  threshold                = var.rds_depth_queue_threshold
  unit                     = "Count"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_read_latency_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_read_latency_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if read latency is > ${var.rds_read_latency_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-RDS-ReadLatencyAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "ReadLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  statistic                = "Average"
  severity                 = var.rds_alarm_severity
  threshold                = var.rds_read_latency_threshold
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_write_latency_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_write_latency_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if write latency is > ${var.rds_write_latency_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-RDS-WriteLatencyAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "WriteLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.rds_alarm_severity
  statistic                = "Average"
  threshold                = var.rds_write_latency_threshold
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

##### Aurora Monitoring #####

module "aurora_high_cpu" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_aurora_nodes
  alarm_description        = "CPU Utilization above ${var.aurora_alarm_cpu_limit} for 15 minutes.  Sending notifications..."
  alarm_name               = "${var.app_name}-Aurora-CPUUtilizationAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.aurora_nodes.*.outputs
  evaluation_periods       = 15
  metric_name              = "CPUUtilization"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.aurora_alarm_severity
  statistic                = "Average"
  unit                     = "Percent"
  threshold                = var.aurora_alarm_cpu_limit
}

resource "aws_cloudwatch_metric_alarm" "aurora_free_memory_alarm" {
  count = var.number_aurora_nodes

  alarm_description   = "Freeable memory is less than ${var.aurora_free_memory_threshold}%"
  alarm_name          = var.number_aurora_nodes > 1 ? format("%v-%03d", "${var.app_name}-Aurora-FreeMemoryAlarm", count.index + 1) : "${var.app_name}-Aurora-FreeMemoryAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  period              = 60
  statistic           = "Average"
  unit                = "Bytes"
  threshold           = floor((var.aurora_free_memory_threshold * 0.01) * (local.aurora_memory[var.aurora_nodes[count.index]["size"]] * 1073741824))
  dimensions          = data.null_data_source.aurora_nodes[count.index].outputs

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions_aurora[local.rackspace_alarm_config_aurora],
  )
  ok_actions = local.rackspace_alarm_actions_aurora[local.rackspace_alarm_config_aurora]
}

module "aurora_read_latency" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.aurora_read_latency_threshold != "" ? var.number_aurora_nodes : 0
  alarm_description        = "Read Latency is above ${var.aurora_read_latency_threshold} seconds"
  alarm_name               = "${var.app_name}-Aurora-ReadLatencyAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.aurora_nodes.*.outputs
  evaluation_periods       = 5
  metric_name              = "ReadLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.aurora_alarm_severity
  statistic                = "Average"
  unit                     = "Seconds"
  threshold                = var.aurora_read_latency_threshold
}

module "aurora_write_latency" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.aurora_write_latency_threshold != "" ? var.number_aurora_nodes : 0
  alarm_description        = "Write Latency is above ${var.aurora_write_latency_threshold} seconds"
  alarm_name               = "${var.app_name}-Aurora-WriteLatencyAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.aurora_nodes.*.outputs
  evaluation_periods       = 5
  metric_name              = "WriteLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.aurora_alarm_severity
  statistic                = "Average"
  unit                     = "Seconds"
  threshold                = var.aurora_write_latency_threshold
}

module "aurora_replica_lag" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_aurora_readers
  alarm_description        = "Replica lag is above ${var.aurora_replica_lag_threshold} milliseconds"
  alarm_name               = "${var.app_name}-Aurora-ReplicaLagAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.aurora_readers.*.outputs
  evaluation_periods       = 10
  metric_name              = "AuroraReplicaLag"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.aurora_alarm_severity
  statistic                = "Average"
  unit                     = "Milliseconds"
  threshold                = var.aurora_replica_lag_threshold
}

# module "write_io_high_aurora" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
#
#   alarm_count              = var.number_aurora_clusters
#   alarm_description        = "Write IO > ${var.aurora_alarm_write_io_limit}, sending notification..."
#   alarm_name               = "${var.app_name}-aurora-write-io-high"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 6
#   metric_name              = "VolumeWriteIOPs"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 300
#   rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.aurora_alarm_write_io_limit
#   dimensions               = data.null_data_source.aurora_clusters.*.outputs
# }
#
# module "read_io_high_aurora" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
#
#   alarm_count              = var.number_aurora_clusters
#   alarm_description        = "Read IO > ${var.aurora_alarm_read_io_limit}, sending notification..."
#   alarm_name               = "${var.app_name}-aurora-read-io-high"
#   comparison_operator      = "GreaterThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = 6
#   metric_name              = "VolumeReadIOPs"
#   namespace                = "AWS/RDS"
#   notification_topic       = var.notification_topic
#   period                   = 300
#   rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.aurora_alarm_read_io_limit
#   dimensions               = data.null_data_source.aurora_clusters.*.outputs
# }

##### EFS Monitoring #####

# module "efs_burst_credits" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
#
#   alarm_count              = var.number_elastic_filesystems
#   alarm_description        = "EFS Burst Credits have dropped below ${var.efs_cw_burst_credit_threshold} for ${var.efs_cw_burst_credit_period} periods."
#   alarm_name               = "${var.app_name}-EFSBurstCredits"
#   comparison_operator      = "LessThanThreshold"
#   customer_alarms_enabled  = true
#   evaluation_periods       = var.efs_cw_burst_credit_period
#   metric_name              = "BurstCreditBalance"
#   namespace                = "AWS/EFS"
#   notification_topic       = var.notification_topic
#   period                   = "3600"
#   rackspace_alarms_enabled = var.efs_rackspace_alarms_enabled
#   rackspace_managed        = true
#   severity                 = "emergency"
#   statistic                = "Minimum"
#   threshold                = var.efs_cw_burst_credit_threshold
#   dimensions               = data.null_data_source.efs.*.outputs
#   unit                     = "Bytes"
# }

resource "aws_cloudwatch_metric_alarm" "efs_permitted_throughput_alarm" {
  count = var.number_elastic_filesystems

  alarm_description   = "Percentage of permitted throughput is bigger than ${var.efs_throughput_percent_threshold}%, creating ticket."
  alarm_name          = var.number_elastic_filesystems > 1 ? format("%v-%03d", "${var.app_name}-EFS-PermittedThroughputAlarm", count.index + 1) : "${var.app_name}-EFS-PermittedThroughputAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  threshold           = var.efs_throughput_percent_threshold

  metric_query {
    id          = "e3"
    expression  = "((e1)*100)/(e2)"
    label       = "ProvisionedThroughputPercentage"
    return_data = "true"
  }

  metric_query {
    id         = "e1"
    expression = "(m1/1048576)/PERIOD(m1)"
    label      = "Expression1"
  }

  metric_query {
    id         = "e2"
    expression = "m2/1048576"
    label      = "Expression2"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "MeteredIOBytes"
      namespace   = "AWS/EFS"
      period      = "60"
      stat        = "Sum"
      unit        = "Bytes"
      dimensions  = data.null_data_source.efs[count.index].outputs
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "PermittedThroughput"
      namespace   = "AWS/EFS"
      period      = "60"
      stat        = "Average"
      unit        = "Bytes/Second"
      dimensions  = data.null_data_source.efs[count.index].outputs
    }
  }

  alarm_actions = concat(
    var.notification_topic,
    local.rackspace_alarm_actions_efs[local.rackspace_alarm_config_efs],
  )
  ok_actions = local.rackspace_alarm_actions_efs[local.rackspace_alarm_config_efs]
}

module "efs_connections_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.efs_connections_threshold != "" ? var.number_elastic_filesystems : 0
  alarm_description        = "Number of connections is above ${var.efs_connections_threshold}, creating a ticket"
  alarm_name               = "${var.app_name}-EFS-ConnectionsAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 10
  metric_name              = "ClientConnections"
  namespace                = "AWS/EFS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.efs_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.efs_alarm_severity
  statistic                = "Sum"
  threshold                = var.efs_connections_threshold
  dimensions               = data.null_data_source.efs.*.outputs
  unit                     = "Count"
}

##### Redshift Monitoring #####

module "redshift_cpu_alarm_high" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Alarm if CPU > ${var.redshift_cw_cpu_threshold}% for 5 minutes"
  alarm_name               = "${var.app_name}-Redshift-CPUUtilizationAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "CPUUtilization"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.redshift_alarm_severity
  statistic                = "Average"
  threshold                = var.redshift_cw_cpu_threshold
  dimensions               = data.null_data_source.redshift.*.outputs
}

module "redshift_cluster_health_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Cluster has entered unhealthy state, creating ticket"
  alarm_name               = "${var.app_name}-Redshift-ClusterHealthAlarm"
  comparison_operator      = "LessThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "HealthStatus"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.redshift_alarm_severity
  statistic                = "Minimum"
  threshold                = 1
  dimensions               = data.null_data_source.redshift.*.outputs
}

module "redshift_free_storage_space_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Consumed storage space has risen above threshold, sending email notification"
  alarm_name               = "${var.app_name}-Redshift-FreeStorageAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 30
  metric_name              = "PercentageDiskSpaceUsed"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.redshift_alarm_severity
  statistic                = "Average"
  threshold                = var.redshift_cw_percentage_disk_used
  unit                     = "Percent"
  dimensions               = data.null_data_source.redshift.*.outputs
}

##### Elasticache Monitoring #####

# module "redis_evictions_alarm" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
#
#   alarm_count              = var.redis_evictions_threshold != "" ? var.number_redis_clusters : 0
#   alarm_description        = "Evictions over ${var.redis_evictions_threshold}"
#   alarm_name               = "Redis-EvictionsAlarm-${var.app_name}"
#   customer_alarms_enabled  = true
#   comparison_operator      = "GreaterThanOrEqualToThreshold"
#   dimensions               = data.null_data_source.redis.*.outputs
#   evaluation_periods       = var.redis_evictions_evaluations
#   metric_name              = "Evictions"
#   namespace                = "AWS/ElastiCache"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.redis_evictions_threshold
# }

module "redis_cpu_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redis_clusters
  alarm_name               = "${var.app_name}-Redis-CPUUtilizationAlarm"
  alarm_description        = "CPUUtilization over ${var.redis_cpu_high_threshold}"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.redis.*.outputs
  evaluation_periods       = var.redis_cpu_high_evaluations
  metric_name              = "CPUUtilization"
  namespace                = "AWS/ElastiCache"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.redis_alarm_severity
  statistic                = "Average"
  threshold                = var.redis_cpu_high_threshold
}

module "redis_memory_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redis_clusters
  alarm_name               = "${var.app_name}-Redis-MemoryUtilizationAlarm"
  alarm_description        = "Memory Utilization over ${var.redis_memory_high_threshold}"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.redis.*.outputs
  evaluation_periods       = var.redis_memory_high_evaluations
  metric_name              = "DatabaseMemoryUsagePercentage"
  namespace                = "AWS/ElastiCache"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.redis_alarm_severity
  statistic                = "Average"
  threshold                = var.redis_memory_high_threshold
}

# module "redis_curr_connections_alarm" {
#   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
#
#   alarm_count              = var.redis_curr_connections_threshold != "" ? var.number_redis_clusters : 0
#   alarm_name               = "Redis-CurrConnectionsAlarm-${var.app_name}"
#   alarm_description        = "CurrConnections over ${var.redis_curr_connections_threshold}"
#   comparison_operator      = "GreaterThanOrEqualToThreshold"
#   customer_alarms_enabled  = true
#   dimensions               = data.null_data_source.redis.*.outputs
#   evaluation_periods       = var.redis_curr_connections_evaluations
#   metric_name              = "CurrConnections"
#   namespace                = "AWS/ElastiCache"
#   notification_topic       = var.notification_topic
#   period                   = 60
#   rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
#   statistic                = "Average"
#   threshold                = var.redis_curr_connections_threshold
# }

####### FSX monitoring #######

module "fsx_free_storage_space_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.fsx_free_space_threshold != "" ? var.number_fsx_filesystems : 0
  alarm_description        = "Free storage space for FSX has fallen below the threshold, generating alarm"
  alarm_name               = "${var.app_name}-FSx-FreeStorageAlarm"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 30
  metric_name              = "FreeStorageCapacity"
  namespace                = "AWS/FSx"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.fsx_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.fsx_alarm_severity
  statistic                = "Average"
  threshold                = var.fsx_free_space_threshold
  unit                     = "Bytes"
  dimensions               = data.null_data_source.fsx.*.outputs
}

####### DynamoDB monitoring #######

module "dynamodb_write_throttling_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.dynamo_write_throttling_threshold != "" ? var.number_dynamo_tables : 0
  alarm_description        = "Sum of write throttling events are above the threshold, generating alarm"
  alarm_name               = "${var.app_name}-DynamoDB-WriteThrottlingAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "WriteThrottleEvents"
  namespace                = "AWS/DynamoDB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.dynamo_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.dynamo_alarm_severity
  statistic                = "Sum"
  threshold                = var.dynamo_write_throttling_threshold
  unit                     = "Count"
  dimensions               = data.null_data_source.dynamodb.*.outputs
}

module "dynamodb_read_throttling_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.dynamo_read_throttling_threshold != "" ? var.number_dynamo_tables : 0
  alarm_description        = "Sum of read throttling events are above the threshold, generating alarm"
  alarm_name               = "${var.app_name}-DynamoDB-ReadThrottlingAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "ReadThrottleEvents"
  namespace                = "AWS/DynamoDB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.dynamo_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = var.dynamo_alarm_severity
  statistic                = "Sum"
  threshold                = var.dynamo_read_throttling_threshold
  unit                     = "Count"
  dimensions               = data.null_data_source.dynamodb.*.outputs
}
