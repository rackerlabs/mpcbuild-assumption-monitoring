variable "app_name" {
  description = "Name of the customer"
  type        = string
}

variable "number_ec2_instances" {
  description = "Number of RDS instances to monitor (don't include instances from ASG's)"
  type        = number
  default     = 0
}

variable "ec2_instance_ids" {
  description = "Identifiers of EC2 instance to monitor (don't include instances from ASG's). The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_win_mem" {
  description = "Number of Windows instances currently with metrics related to memory usage"
  type        = number
  default     = 0
}

variable "win_mem_list" {
  description = "Maps for the Windows instances including the total available memory"
  type        = list(map(string))
  default     = [{}]
}

variable "number_win_disk" {
  description = "Number of EBS volumes associated to Windows instances that are currently reporting metrics"
  type        = number
  default     = 0
}

variable "win_disk_list" {
  description = "Maps for the Windows instances including the device units associated to the volumes"
  type        = list(map(string))
  default     = [{}]
}

variable "number_lin_mem" {
  description = "Number of Linux instances currently with metrics related to memory usage"
  type        = number
  default     = 0
}

variable "lin_mem_list" {
  description = "List of Linux instances reporting memory metrics"
  type        = list(string)
  default     = []
}

variable "number_lin_disk" {
  description = "Number of EBS volumes associated to Linux instances that are currently reporting metrics"
  type        = number
  default     = 0
}

variable "lin_disk_list" {
  description = "Maps for the Linux instances including the device names associated to the volumes"
  type        = list(map(string))
  default     = [{}]
}

variable "number_asg" {
  description = "Number of AutoScaling Groups to monitor "
  type        = number
  default     = 0
}

variable "asg_names" {
  description = "Names of ASG to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_alb_tg" {
  description = "Number of ALB's & Target group combinations to monitor."
  type        = number
  default     = 0
}

variable "alb_tg_list" {
  description = "Maps representing ALB and Target Groups combinations to monitor. Example: [{alb_prefix = 'app/alb-test/xxxxxxxxx', tg_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]."
  type        = list(map(string))
  default     = [{}]
}

variable "number_nlb_tg" {
  description = "Number of NLB's & Target group combinations to monitor."
  type        = number
  default     = 0
}

variable "nlb_tg_list" {
  description = "Maps representing NLB and Target Groups combinations to monitor. Example: [{nlb_prefix = 'net/nlb-test/xxxxxxxxx', tg_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]."
  type        = list(map(string))
  default     = [{}]
}

variable "number_ecs_services" {
  description = "Number of ECS services per cluster to monitor"
  type        = number
  default     = 0
}

variable "ecs_services_list" {
  description = "Maps representing the ECS cluster/service combination. Example: [{cluster = 'cluster1', service = 'service1'}]."
  type        = list(map(string))
  default     = [{}]
}

variable "number_lambda_functions" {
  description = "Number of Lambda functions to monitor"
  type        = number
  default     = 0
}

variable "lambda_names" {
  description = "Name of the Lambda functions to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_cloudfront_distributions" {
  description = "Number of Cloudfront distributions to monitor"
  type        = number
  default     = 0
}

variable "cloudfront_distribution_ids" {
  description = "Cloudfront Id's to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "number_api_gws" {
  description = "Number of API GW's to monitor"
  type        = number
  default     = 0
}

variable "api_gw_names" {
  description = "Name of the API GW's to monitor. The list should match the length specified"
  type        = list(string)
  default     = []
}

variable "notification_topic" {
  description = "The SNS topic to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "ec2_rackspace_alarms_enabled" {
  description = "Specifies whether EC2 alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "asg_rackspace_alarms_enabled" {
  description = "Specifies whether ASG alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "elb_rackspace_alarms_enabled" {
  description = "Specifies whether ELB alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "ecs_rackspace_alarms_enabled" {
  description = "Specifies whether ECS alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "lambda_rackspace_alarms_enabled" {
  description = "Specifies whether Lambda alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "cloudfront_rackspace_alarms_enabled" {
  description = "Specifies whether Cloudfront alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "api_gw_rackspace_alarms_enabled" {
  description = "Specifies whether API GW alarms will create a Rackspace ticket"
  type        = bool
  default     = true
}

variable "ec2_alarm_severity" {
  description = "Severity of the alarm triggered for EC2. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "asg_alarm_severity" {
  description = "Severity of the alarm triggered for ASG. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "elb_alarm_severity" {
  description = "Severity of the alarm triggered for ALB/NLB. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "ecs_alarm_severity" {
  description = "Severity of the alarm triggered for ECS. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "lambda_alarm_severity" {
  description = "Severity of the alarm triggered for Lambda. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "cloudfront_alarm_severity" {
  description = "Severity of the alarm triggered for Cloudfront. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "api_gw_alarm_severity" {
  description = "Severity of the alarm triggered for API Gateway. Can be emergency, urgent or standard"
  type        = string
  default     = "urgent"
}

variable "enable_recovery_alarms" {
  description = "Boolean parameter controlling if auto-recovery alarms should be created.  Recovery actions are not supported on all instance types and AMIs, especially those with ephemeral storage.  This parameter should be set to false for those cases."
  type        = bool
  default     = true
}

variable "ec2_cw_cpu_high_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold on EC2 alarm"
  type        = number
  default     = 15
}

variable "ec2_cw_cpu_high_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers on EC2 alarm"
  type        = string
  default     = "GreaterThanThreshold"
}

variable "ec2_cw_cpu_high_period" {
  description = "Time the specified statistic is applied on EC2 alarm. Must be in seconds that is also a multiple of 60."
  type        = number
  default     = 60
}

variable "ec2_cw_cpu_high_threshold" {
  description = "The value against which the specified statistic is compared on EC2 alarm."
  type        = number
  default     = 90
}

variable "cw_namespace_linux" {
  description = "Namespace for the custom metrics on Linux Instances"
  type        = string
  default     = "CWAgent"
}

variable "cw_namespace_windows" {
  description = "Namespace for the custom metrics on Windows Instances"
  type        = string
  default     = "CWAgent"
}

variable "ec2_memory_linux_threshold" {
  description = "Maximum memory utilization before triggering an alarm. Only applies for Linux instances"
  type        = number
  default     = 90
}

variable "ec2_disk_linux_threshold" {
  description = "Maximum EBS volume utilization before triggering an alarm. Only applies for Linux instances"
  type        = number
  default     = 90
}

variable "ec2_memory_windows_threshold" {
  description = "Minimum memory utilization before triggering an alarm. Only applies for Windows instances"
  type        = number
  default     = 10
}

variable "ec2_disk_windows_threshold" {
  description = "Minimum EBS volume utilization before triggering an alarm. Only applies for Windows instances"
  type        = number
  default     = 10
}

variable "asg_terminated_instances" {
  description = "Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm."
  type        = string
  default     = "30"
}

variable "alb_unhealthy_target_threshold" {
  description = "The value against which the calculation of unhealthy hosts behind an ALB. If this value is empty, an alarm that detects any unhealthy host will be created"
  type        = string
  default     = ""
}

variable "nlb_unhealthy_target_threshold" {
  description = "The value against which the calculation of unhealthy hosts behind an NLB. If this value is empty, an alarm that detects any unhealthy host will be created"
  type        = string
  default     = ""
}

variable "alb_response_time_threshold" {
  description = "The value against which the specified statistic is compared on ALB response time alarm"
  type        = string
  default     = ""
}

variable "ecs_cpu_high_threshold" {
  description = "The value against which the specified statistic is compared on ECS CPU alarm."
  type        = number
  default     = 75
}

variable "ecs_memory_high_threshold" {
  description = "The value against which the specified statistic is compared on ECS memory alarm."
  type        = number
  default     = 75
}

variable "cloudfront_total_errors_threshold" {
  description = "Maximum percentage of total errors on Cloudfront requests allowed before sending an alarms"
  type        = string
  default     = ""
}

variable "cloudfront_500_errors_threshold" {
  description = "Maximum percentage of 500 errors (backend errors) on Cloudfront requests allowed before sending an alarms"
  type        = string
  default     = ""
}

variable "api_gw_500_errors_threshold" {
  description = "Maximum number of 500 errors (backend errors) on API GW requests allowed before sending an alarms"
  type        = string
  default     = ""
}

variable "api_gw_400_errors_threshold" {
  description = "Maximum number of 400 errors (backend errors) on API GW requests allowed before sending an alarms"
  type        = string
  default     = ""
}

variable "api_gw_latency_threshold" {
  description = "Maximum latency time in milliseconds on API GW requests allowed before sending an alarms"
  type        = string
  default     = ""
}
