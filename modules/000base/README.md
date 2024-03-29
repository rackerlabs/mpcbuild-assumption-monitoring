## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_evaluations\_vpn | The number of periods over which data is evaluated to monitor VPN connection status. | `number` | `5` | no |
| alarm\_period\_vpn | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| app\_name | Name of the customer | `string` | n/a | yes |
| backup\_tag\_key | Backup tag key used for AWS Backup selection | `string` | `"Backup"` | no |
| backup\_tag\_value | Backup Tag value used for AWS Backup selection | `string` | `"True"` | no |
| completion\_window\_backup | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Defaults to 8 hours. Completion windows only apply to EFS backups. | `number` | `480` | no |
| create\_backup\_role | Flag to create IAM role for AWS backup. Only needed once if working with multiple regions | `bool` | `false` | no |
| dx\_alarm\_severity | Severity of the alarm triggered for Direct Connect status. Can be emergency, urgent or standard | `string` | `"emergency"` | no |
| dx\_connections\_ids | Direct Connect connection ID's to be monitored. The list should match the length specified | `list(string)` | `[]` | no |
| dx\_rackspace\_alarms\_enabled | Specifies whether Direct Connect alarms will create a Rackspace ticket. | `bool` | `true` | no |
| enable\_aws\_backup | Flag to create full AWS backup solution | `bool` | `false` | no |
| environment | Environment deployed | `string` | n/a | yes |
| existing\_sns\_topic | The ARN of an existing SNS topic, in case the customer wants to send the notification there instead of using a new topic | `string` | `""` | no |
| health\_check\_ids | Route53 Health Check Id's to be monitored. The list should match the length specified | `list(string)` | `[]` | no |
| number\_dx\_connections | Number of Direct Connect connections to monitor | `number` | `0` | no |
| number\_health\_checks | Route53 Health checks to monitor | `number` | `0` | no |
| number\_vpn\_connections | Number of VPN connections to monitor | `number` | `0` | no |
| r53\_alarm\_severity | Severity of the alarm triggered for Route53 HC status. Can be emergency, urgent or standard | `string` | `"emergency"` | no |
| r53\_rackspace\_alarms\_enabled | Specifies whether Route53 HC alarms will create a Rackspace ticket. | `bool` | `true` | no |
| retention\_period\_backup | Number of days that the EC2 AMI's (snapshots) will be retained | `number` | `15` | no |
| schedule\_backup | A CRON expression specifying when AWS Backup initiates a backup job. Default is 05:00 UTC every day. Consult https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for expression help. | `string` | `"cron(0 5 ? * * *)"` | no |
| start\_window\_backup | The amount of time in minutes after a backup is scheduled before a job is canceled if it doesn't start successfully. Minimum and Default value is 60. Max is 720 (12 Hours). | `number` | `60` | no |
| vpn\_alarm\_severity | Severity of the alarm triggered for VPN status. Can be emergency, urgent or standard | `string` | `"emergency"` | no |
| vpn\_connections\_ids | VPN Connections ID's to be monitored. The list should match the length specified | `list(string)` | `[]` | no |
| vpn\_rackspace\_alarms\_enabled | Specifies whether VPN alarms will create a Rackspace ticket. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns\_topic | SNS ARN for monitoring |

