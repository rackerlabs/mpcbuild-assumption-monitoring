variable "environment" {
  description = "Environment deployed"
  type        = string
}

variable "app_name" {
  description = "Name of the customer"
  type        = string
}

variable "enable_aws_backup" {
  description = "Flag to create full AWS backup solution"
  type        = bool
  default     = false
}

variable "create_backup_role" {
  description = "Flag to create IAM role for AWS backup. Only needed once if working with multiple regions"
  type        = bool
  default     = false
}

variable "backup_tag_key" {
  description = "Backup tag key used for AWS Backup selection"
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Backup Tag value used for AWS Backup selection"
  type        = string
  default     = "True"
}

variable "completion_window_backup" {
  description = "The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Defaults to 8 hours. Completion windows only apply to EFS backups."
  type        = number
  default     = 480
}

variable "schedule_backup" {
  description = "A CRON expression specifying when AWS Backup initiates a backup job. Default is 05:00 UTC every day. Consult https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for expression help."
  type        = string
  default     = "cron(0 5 ? * * *)"
}

variable "start_window_backup" {
  description = "The amount of time in minutes after a backup is scheduled before a job is canceled if it doesn't start successfully. Minimum and Default value is 60. Max is 720 (12 Hours)."
  type        = number
  default     = 60
}

variable "retention_period_backup" {
  description = "Number of days that the EC2 AMI's (snapshots) will be retained"
  type        = number
  default     = 15
}

variable "number_vpn_connections" {
  description = "Number of VPN connections to monitor"
  type        = number
  default     = 0
}

variable "vpn_connections_ids" {
  description = "VPN Connections ID's to be monitored. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_dx_connections" {
  description = "Number of Direct Connect connections to monitor"
  type        = number
  default     = 0
}

variable "dx_connections_ids" {
  description = "Direct Connect connection ID's to be monitored. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_health_checks" {
  description = "Route53 Health checks to monitor"
  type        = number
  default     = 0
}

variable "health_check_ids" {
  description = "Route53 Health Check Id's to be monitored. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "vpn_rackspace_alarms_enabled" {
  description = "Specifies whether VPN alarms will create a Rackspace ticket."
  type        = bool
  default     = true
}

variable "dx_rackspace_alarms_enabled" {
  description = "Specifies whether Direct Connect alarms will create a Rackspace ticket."
  type        = bool
  default     = true
}

variable "r53_rackspace_alarms_enabled" {
  description = "Specifies whether Route53 HC alarms will create a Rackspace ticket."
  type        = bool
  default     = true
}

variable "alarm_evaluations_vpn" {
  description = "The number of periods over which data is evaluated to monitor VPN connection status."
  type        = number
  default     = 5
}

variable "alarm_period_vpn" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = number
  default     = 60
}

variable "vpn_alarm_severity" {
  description = "Severity of the alarm triggered for VPN status. Can be emergency, urgent or standard"
  type        = string
  default     = "emergency"
}

variable "dx_alarm_severity" {
  description = "Severity of the alarm triggered for Direct Connect status. Can be emergency, urgent or standard"
  type        = string
  default     = "emergency"
}

variable "r53_alarm_severity" {
  description = "Severity of the alarm triggered for Route53 HC status. Can be emergency, urgent or standard"
  type        = string
  default     = "emergency"
}

variable "existing_sns_topic" {
  description = "The ARN of an existing SNS topic, in case the customer wants to send the notification there instead of using a new topic"
  type        = string
  default     = ""
}
