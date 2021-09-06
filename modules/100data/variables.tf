variable "app_name" {
  description = "Name of the customer"
  type        = string
}

variable "number_rds_instances" {
  description = "Number of RDS instances to monitor (without read replicas)"
  type        = number
  default     = 0
}

# variable "rds_instance_identifiers" {
#   description = "Identifiers of RDS instance to monitor (without read replicas). The list should match the length specified"
#   type        = list(string)
#   default     = []
# }

variable "rds_instances_list" {
  description = "Maps including the RDS instance identifier and the storage allocated"
  type        = list(map(string))
  default     = [{}]
}

variable "number_rds_read_replicas" {
  description = "Number of RDS read replicas to monitor"
  type        = number
  default     = 0
}

# variable "read_replicas_identifiers" {
#   description = "Identifiers of RDS read replicas to monitor. The list should match the length specified"
#   type        = list(string)
#   default     = []
# }

variable "rds_replicas_list" {
  description = "Maps including the RDS instance identifier of the replica and the storage allocated"
  type        = list(map(string))
  default     = [{}]
}

variable "number_aurora_clusters" {
  description = "Number of Aurora Cluster to monitor"
  type        = number
  default     = 0
}

variable "aurora_clusters" {
  description = "Maps representing Aurora Clusters to monitor. Example: [{cluster_id = 'aurora-test', engine = 'aurora-mysql'}]. The nodes will be handled in another parameter"
  type        = list(map(string))
  default     = [{}]
}

variable "number_aurora_nodes" {
  description = "Number of Aurora Nodes (writer and reader nodes) to monitor"
  type        = number
  default     = 0
}

variable "aurora_nodes" {
  description = "Identifiers for all Aurora nodes (writer and reader nodes) to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_redshift_nodes" {
  description = "Number of Redshift nodes to monitor"
  type        = number
  default     = 0
}

variable "redshift_nodes_ids" {
  description = "Identifiers of Redshift nodes to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_elastic_filesystems" {
  description = "Number of EFS to monitor"
  type        = number
  default     = 0
}

variable "elastic_filesystem_ids" {
  description = "Identifiers of EFS to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_redis_clusters" {
  description = "Number of Redis clusters to monitor"
  type        = number
  default     = 0
}

variable "redis_cluster_ids" {
  description = "Identifiers of Redis clusters to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_fsx_filesystems" {
  description = "Number of FSX filesystems to monitor"
  type        = number
  default     = 0
}

variable "fsx_ids" {
  description = "Identifiers of FSX filesystems to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_dynamo_tables" {
  description = "Number of provisioned DynamoDB tables"
  type        = number
  default     = 0
}

variable "dynamo_tables" {
  description = "Identifiers of DynamoDB tables to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "notification_topic" {
  description = "The SNS topic to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "rds_rackspace_alarms_enabled" {
  description = "Specifies whether RDS alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "aurora_rackspace_alarms_enabled" {
  description = "Specifies whether Aurora alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "efs_rackspace_alarms_enabled" {
  description = "Specifies whether EFS alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "redshift_rackspace_alarms_enabled" {
  description = "Specifies whether Redshift alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "redis_rackspace_alarms_enabled" {
  description = "Specifies whether Redis (Elasticache) alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "fsx_rackspace_alarms_enabled" {
  description = "Specifies whether FSX alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "dynamo_rackspace_alarms_enabled" {
  description = "Specifies whether Dynamo alarms will create a Rackspace ticket."
  type        = bool
  default     = false
}

variable "rds_alarm_cpu_limit" {
  description = "CloudWatch CPUUtilization Threshold for RDS"
  type        = number
  default     = 75
}

# variable "rds_alarm_free_space_limit" {
#   description = "CloudWatch Free Storage Space Limit Threshold (Bytes) for RDS"
#   type        = number
#   default     = 1024000000
# }

variable "rds_alarm_free_space_threshold" {
  description = "Minimum percentage of Free Storage Space for RDS before triggering an alarm"
  type        = number
  default     = 10
}

variable "rds_alarm_read_iops_limit" {
  description = "CloudWatch Read IOPSLimit Threshold for RDS"
  type        = number
  default     = 100
}

variable "rds_replica_lag_threshold" {
  description = "Maximum lag in seconds allowed before triggering an alarm"
  type        = number
  default     = 600
}

variable "rds_depth_queue_threshold" {
  description = "RDS depth queue limit for an alarm"
  type        = string
  default     = ""
}

variable "rds_read_latency_threshold" {
  description = "RDS read latency limit for an alarm"
  type        = string
  default     = ""
}

variable "rds_write_latency_threshold" {
  description = "RDS write latency limit for an alarm"
  type        = string
  default     = ""
}

variable "rds_alarm_write_iops_limit" {
  description = "CloudWatch Write IOPSLimit Threshold for RDS"
  type        = number
  default     = 100
}

variable "aurora_alarm_cpu_limit" {
  description = "CloudWatch CPUUtilization Threshold for Aurora"
  type        = number
  default     = 75
}

variable "aurora_free_memory_threshold" {
  description = "Minimum percentage of freeable memory on Aurora before triggering an alarm"
  type        = number
  default     = 10
}

variable "aurora_read_latency_threshold" {
  description = "Maximum time in seconds of latency in read operations on Aurora before triggering an alarm"
  type        = string
  default     = ""
}

variable "aurora_write_latency_threshold" {
  description = "Maximum time in seconds of latency in write operations on Aurora before triggering an alarm"
  type        = string
  default     = ""
}

# variable "aurora_alarm_read_io_limit" {
#   description = "CloudWatch Read IOPSLimit Threshold for Aurora"
#   type        = number
#   default     = 60
# }
#
# variable "aurora_alarm_write_io_limit" {
#   description = "CloudWatch Write IOPSLimit Threshold for Aurora"
#   type        = number
#   default     = 100000
# }

variable "efs_cw_burst_credit_period" {
  description = "The number of periods over which the EFS Burst Credit level is compared to the specified threshold."
  type        = number
  default     = 12
}

variable "efs_cw_burst_credit_threshold" {
  description = "The minimum EFS Burst Credit level before generating an alarm."
  type        = number
  default     = 1000000000000
}

variable "redshift_cw_cpu_threshold" {
  description = "CloudWatch CPUUtilization Threshold for Redshift"
  default     = 90
  type        = number
}

variable "redshift_cw_percentage_disk_used" {
  description = "CloudWatch Percentage of storage consumed threshold for Redshift"
  default     = 90
  type        = number
}

variable "redis_evictions_evaluations" {
  description = "(redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "redis_evictions_threshold" {
  description = "(redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned."
  type        = string
  default     = ""
}

variable "redis_cpu_high_evaluations" {
  description = "(redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "redis_cpu_high_threshold" {
  description = "(redis) The max CPU Usage % before generating an alarm."
  type        = number
  default     = 75
}

variable "redis_memory_high_evaluations" {
  description = "(redis) The number of minutes memory usage must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "redis_memory_high_threshold" {
  description = "(redis) The max memory usage % before generating an alarm."
  type        = number
  default     = 75
}

variable "redis_curr_connections_evaluations" {
  description = "(redis) The number of minutes current connections must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "redis_curr_connections_threshold" {
  description = "(redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned."
  type        = string
  default     = ""
}

variable "fsx_free_space_threshold" {
  description = "Free Storage Space Limit Threshold (Bytes) for FSX"
  type        = string
  default     = ""
}

variable "dynamo_write_throttling_threshold" {
  description = "Number of write throttling events on DynamoDB that will trigger an alarm"
  type        = string
  default     = ""
}

variable "dynamo_read_throttling_threshold" {
  description = "Number of read throttling events on DynamoDB that will trigger an alarm"
  type        = string
  default     = ""
}
