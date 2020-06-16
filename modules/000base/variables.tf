variable "environment" {
  description = "Environment deployed"
  type        = string
}

variable "app_name" {
  description = "Name of the customer"
  type        = string
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

variable "alarm_evaluations_vpn" {
  description = "The number of periods over which data is evaluated to monitor VPN connection status."
  type        = number
  default     = 10
}

variable "alarm_period_vpn" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = number
  default     = 60
}
