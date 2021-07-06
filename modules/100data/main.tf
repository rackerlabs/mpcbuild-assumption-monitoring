terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.70.0"
  }
}

##### Placeholder for each service #####

data "null_data_source" "rds_instances" {
  count = var.number_rds_instances
  inputs = {
    DBInstanceIdentifier = element(var.rds_instance_identifiers, count.index)
  }
}

data "null_data_source" "rds_read_replicas" {
  count = var.number_rds_read_replicas
  inputs = {
    DBInstanceIdentifier = element(var.read_replicas_identifiers, count.index)
  }
}

data "null_data_source" "aurora_clusters" {
  count = var.number_aurora_clusters
  inputs = {
    DbClusterIdentifier = lookup(var.aurora_clusters[count.index], "cluster_id")
    EngineName          = lookup(var.aurora_clusters[count.index], "engine")
  }
}

data "null_data_source" "aurora_nodes" {
  count = var.number_aurora_nodes
  inputs = {
    DBInstanceIdentifier = element(var.aurora_nodes, count.index)
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

##### RDS Monitoring #####

module "rds_free_storage_space_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Free storage space has fallen below threshold, generating ticket."
  alarm_name               = "${var.app_name}-rds-free-storage-ticket"
  comparison_operator      = "LessThanOrEqualToThreshold"
  evaluation_periods       = 30
  metric_name              = "FreeStorageSpace"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = var.rds_alarm_free_space_limit
  unit                     = "Bytes"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_free_storage_space_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Free storage space has fallen below threshold, generating ticket."
  alarm_name               = "${var.app_name}-rds-replica-free-storage-ticket"
  comparison_operator      = "LessThanOrEqualToThreshold"
  evaluation_periods       = 30
  metric_name              = "FreeStorageSpace"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = var.rds_alarm_free_space_limit
  unit                     = "Bytes"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_free_storage_space_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Free storage space has fallen below threshold, sending email notification."
  alarm_name               = "${var.app_name}-rds-free-storage-space-email"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 30
  metric_name              = "FreeStorageSpace"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.rds_alarm_free_space_limit
  unit                     = "Bytes"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_free_storage_space_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Free storage space has fallen below threshold, sending email notification."
  alarm_name               = "${var.app_name}-rds-replica-free-storage-space-email"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 30
  metric_name              = "FreeStorageSpace"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.rds_alarm_free_space_limit
  unit                     = "Bytes"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_write_iops_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Alarm if WriteIOPs > ${var.rds_alarm_write_iops_limit} for 5 minutes"
  alarm_name               = "${var.app_name}-rds-write-iops-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "WriteIOPS"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_write_iops_limit
  unit                     = "Count/Second"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_write_iops_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Alarm if WriteIOPs > ${var.rds_alarm_write_iops_limit} for 5 minutes"
  alarm_name               = "${var.app_name}-rds-replica-write-iops-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "WriteIOPS"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_write_iops_limit
  unit                     = "Count/Second"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_read_iops_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Alarm if ReadIOPs > ${var.rds_alarm_read_iops_limit} for 5 minutes"
  alarm_name               = "${var.app_name}-rds-read-iops-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "ReadIOPS"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_read_iops_limit
  unit                     = "Count/Second"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_read_iops_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Alarm if ReadIOPs > ${var.rds_alarm_read_iops_limit} for 5 minutes"
  alarm_name               = "${var.app_name}-rds-replica-read-iops-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "ReadIOPS"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_read_iops_limit
  unit                     = "Count/Second"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_cpu_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_instances
  alarm_description        = "Alarm if CPU > ${var.rds_alarm_cpu_limit} for 15 minutes"
  alarm_name               = "${var.app_name}-rds-cpu-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "CPUUtilization"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_cpu_limit
  unit                     = "Percent"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_replica_cpu_high_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "Alarm if CPU > ${var.rds_alarm_cpu_limit} for 15 minutes"
  alarm_name               = "${var.app_name}-rds-replica-cpu-high-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "CPUUtilization"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_alarm_cpu_limit
  unit                     = "Percent"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "replica_lag_alarm_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "ReplicaLag has exceeded threshold, generating ticket.."
  alarm_name               = "${var.app_name}-replica-lag-ticket"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = 5
  metric_name              = "ReplicaLag"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = 3600
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "replica_lag_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.number_rds_read_replicas
  alarm_description        = "ReplicaLag has exceeded threshold."
  alarm_name               = "${var.app_name}-replica-lag-email"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 3
  metric_name              = "ReplicaLag"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = 3600
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_read_replicas.*.outputs
}

module "rds_depth_queue_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_depth_queue_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if Depth queue is > ${var.rds_depth_queue_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-rds-depth-queue-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "DiskQueueDepth"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_depth_queue_threshold
  unit                     = "Count"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_read_latency_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_read_latency_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if read latency is > ${var.rds_read_latency_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-rds-read-latency-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "ReadLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_read_latency_threshold
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

module "rds_write_latency_alarm_email" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm?ref=v0.12.6"

  alarm_count              = var.rds_write_latency_threshold != "" ? var.number_rds_instances : 0
  alarm_description        = "Alarm if write latency is > ${var.rds_write_latency_threshold} for 15 minutes"
  alarm_name               = "${var.app_name}-rds-write-latency-email"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 15
  metric_name              = "WriteLatency"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rds_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.rds_write_latency_threshold
  unit                     = "Seconds"
  dimensions               = data.null_data_source.rds_instances.*.outputs
}

##### Aurora Monitoring #####

module "high_cpu_aurora" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_aurora_nodes
  alarm_description        = "CPU Utilization above ${var.aurora_alarm_cpu_limit} for 15 minutes.  Sending notifications..."
  alarm_name               = "${var.app_name}-aurora-high-cpu"
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
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = var.aurora_alarm_cpu_limit
}

module "write_io_high_aurora" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_aurora_clusters
  alarm_description        = "Write IO > ${var.aurora_alarm_write_io_limit}, sending notification..."
  alarm_name               = "${var.app_name}-aurora-write-io-high"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 6
  metric_name              = "VolumeWriteIOPs"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 300
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.aurora_alarm_write_io_limit
  dimensions               = data.null_data_source.aurora_clusters.*.outputs
}

module "read_io_high_aurora" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_aurora_clusters
  alarm_description        = "Read IO > ${var.aurora_alarm_read_io_limit}, sending notification..."
  alarm_name               = "${var.app_name}-aurora-read-io-high"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 6
  metric_name              = "VolumeReadIOPs"
  namespace                = "AWS/RDS"
  notification_topic       = var.notification_topic
  period                   = 300
  rackspace_alarms_enabled = var.aurora_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.aurora_alarm_read_io_limit
  dimensions               = data.null_data_source.aurora_clusters.*.outputs
}

##### EFS Monitoring #####

module "efs_burst_credits" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_elastic_filesystems
  alarm_description        = "EFS Burst Credits have dropped below ${var.efs_cw_burst_credit_threshold} for ${var.efs_cw_burst_credit_period} periods."
  alarm_name               = "${var.app_name}-EFSBurstCredits"
  comparison_operator      = "LessThanThreshold"
  evaluation_periods       = var.efs_cw_burst_credit_period
  metric_name              = "BurstCreditBalance"
  namespace                = "AWS/EFS"
  notification_topic       = var.notification_topic
  period                   = "3600"
  rackspace_alarms_enabled = var.efs_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = var.efs_cw_burst_credit_threshold
  dimensions               = data.null_data_source.efs.*.outputs
  unit                     = "Bytes"
}

##### Redshift Monitoring #####

module "redshift_cpu_alarm_high" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Alarm if CPU > ${var.redshift_cw_cpu_threshold}% for 5 minutes"
  alarm_name               = "${var.app_name}-Redshift-CPUAlarmHigh"
  comparison_operator      = "GreaterThanThreshold"
  evaluation_periods       = 5
  metric_name              = "CPUUtilization"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = var.redshift_cw_cpu_threshold
  dimensions               = data.null_data_source.redshift.*.outputs
}

module "redshift_cluster_health_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Cluster has entered unhealthy state, creating ticket"
  alarm_name               = "${var.app_name}-Redshift-CluterHealthTicket"
  comparison_operator      = "LessThanThreshold"
  evaluation_periods       = 5
  metric_name              = "HealthStatus"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = 1
  dimensions               = data.null_data_source.redshift.*.outputs
}

module "redshift_free_storage_space_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.number_redshift_nodes
  alarm_description        = "Consumed storage space has risen above threshold, sending email notification"
  alarm_name               = "${var.app_name}-Redshift-FreeStorageSpaceTicket"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = 30
  metric_name              = "PercentageDiskSpaceUsed"
  namespace                = "AWS/Redshift"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redshift_rackspace_alarms_enabled
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = var.redshift_cw_percentage_disk_used
  unit                     = "Percent"
  dimensions               = data.null_data_source.redshift.*.outputs
}

##### Elasticache Monitoring #####

module "redis_evictions_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.redis_evictions_threshold != "" ? var.number_redis_clusters : 0
  alarm_description        = "Evictions over ${var.redis_evictions_threshold}"
  alarm_name               = "${var.app_name}-Redis-EvictionsAlarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.redis.*.outputs
  evaluation_periods       = var.redis_evictions_evaluations
  metric_name              = "Evictions"
  namespace                = "AWS/ElastiCache"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.redis_evictions_threshold
}

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
  statistic                = "Average"
  threshold                = var.redis_memory_high_threshold
}

module "redis_curr_connections_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.redis_curr_connections_threshold != "" ? var.number_redis_clusters : 0
  alarm_name               = "${var.app_name}-Redis-CurrConnectionsAlarm"
  alarm_description        = "CurrConnections over ${var.redis_curr_connections_threshold}"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.redis.*.outputs
  evaluation_periods       = var.redis_curr_connections_evaluations
  metric_name              = "CurrConnections"
  namespace                = "AWS/ElastiCache"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.redis_rackspace_alarms_enabled
  statistic                = "Average"
  threshold                = var.redis_curr_connections_threshold
}
