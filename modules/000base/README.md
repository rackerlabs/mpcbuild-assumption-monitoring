# mpcbuild-assumption-monitoring/modules/000base
Module to deploy monitoring for resources on base layer (including SNS topic for customer subscriptions). Also, AWS backup can be deployed if needed.

## Basic Usage
```HCL
module "base" {
	source 	= "git@github.com:rackerlabs/mpcbuild-assumption-monitoring//modules/000base/?ref=v0.13.0"
	app_name 		= "test"
	environment 		= "Development"
	number_vpn_connections 	= 1
	vpn_connections_ids 	= ["vpn-0922b27c08a34cb93"]
	enable_aws_backup       = true
	create_backup_role      = true
}
```

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_evaluations\_vpn | The number of periods over which data is evaluated to monitor VPN connection status. | `number` | `10` | no |
| alarm\_period\_vpn | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| app\_name | Name of the customer | `string` | n/a | yes |
| backup\_tag\_key | Backup tag key used for AWS Backup selection | `string` | `"Backup"` | no |
| backup\_tag\_value | Backup Tag value used for AWS Backup selection | `string` | `"True"` | no |
| completion\_window\_backup | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Defaults to 8 hours. Completion windows only apply to EFS backups. | `number` | `480` | no |
| create\_backup\_role | Flag to create IAM role for AWS backup. Only needed once if working with multiple regions | `bool` | `false` | no |
| enable\_aws\_backup | Flag to create full AWS backup solution | `bool` | `false` | no |
| environment | Environment deployed | `string` | n/a | yes |
| number\_vpn\_connections | Number of VPN connections to monitor | `number` | `0` | no |
| retention\_period\_backup | Number of days that the EC2 AMI's (snapshots) will be retained | `number` | `15` | no |
| schedule\_backup | A CRON expression specifying when AWS Backup initiates a backup job. Default is 05:00 UTC every day. Consult https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for expression help. | `string` | `"cron(0 5 ? * * *)"` | no |
| start\_window\_backup | The amount of time in minutes after a backup is scheduled before a job is canceled if it doesn't start successfully. Minimum and Default value is 60. Max is 720 (12 Hours). | `number` | `60` | no |
| vpn\_connections\_ids | VPN Connections ID's to be monitored. The list should match the length specified | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns\_topic | SNS ARN for monitoring |

