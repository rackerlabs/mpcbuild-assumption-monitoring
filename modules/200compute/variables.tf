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
  default     = false
}

variable "elb_rackspace_alarms_enabled" {
  description = "Specifies whether ELB alarms will create a Rackspace ticket"
  type        = bool
  default     = false
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

variable "asg_enable_scaling_actions" {
  description = "Should this autoscaling group be configured with scaling alarms to manage the desired count.  Set this variable to false if another process will manage the desired count, such as EKS Cluster Autoscaler."
  type        = bool
  default     = false
}

variable "asg_ec2_scale_down_adjustment" {
  description = "Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative."
  type        = string
  default     = "-1"
}

variable "asg_ec2_scale_down_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = string
  default     = "60"
}

variable "asg_ec2_scale_up_adjustment" {
  description = "Number of EC2 instances to scale up by at a time."
  type        = string
  default     = "1"
}

variable "asg_ec2_scale_up_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = string
  default     = "60"
}

variable "asg_terminated_instances" {
  description = "Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm."
  type        = string
  default     = "30"
}

variable "asg_cw_high_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = string
  default     = "3"
}

variable "asg_cw_high_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers on ASG (high threshold)."
  type        = string
  default     = "GreaterThanThreshold"
}

variable "asg_cw_high_period" {
  description = "Time the specified statistic is applied on ASG (high threshold). Must be in seconds that is also a multiple of 60."
  type        = string
  default     = "60"
}

variable "asg_cw_high_threshold" {
  description = "The value against which the specified statistic is compared on ASG (high threshold)."
  type        = string
  default     = "60"
}

variable "asg_cw_low_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold on ASG (low)."
  type        = string
  default     = "3"
}

variable "asg_cw_low_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers on ASG (low threshold)."
  type        = string
  default     = "LessThanThreshold"
}

variable "asg_cw_low_period" {
  description = "Time the specified statistic is applied on ASG (low threshold). Must be in seconds that is also a multiple of 60."
  type        = string
  default     = "300"
}

variable "asg_cw_low_threshold" {
  description = "The value against which the specified statistic is compared on ASG (low threshold)."
  type        = string
  default     = "30"
}

variable "asg_cw_scaling_metric" {
  description = "The metric to be used for scaling on ASG."
  type        = string
  default     = "CPUUtilization"
}
