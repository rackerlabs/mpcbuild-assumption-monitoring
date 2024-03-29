## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alb\_response\_time\_threshold | The value against which the specified statistic is compared on ALB response time alarm | `string` | `""` | no |
| alb\_tg\_list | Maps representing ALB and Target Groups combinations to monitor. Example: [{alb\_prefix = 'app/alb-test/xxxxxxxxx', tg\_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| alb\_unhealthy\_target\_threshold | The value against which the calculation of unhealthy hosts behind an ALB. If this value is empty, an alarm that detects any unhealthy host will be created | `string` | `""` | no |
| api\_gw\_400\_errors\_threshold | Maximum number of 400 errors (backend errors) on API GW requests allowed before sending an alarms | `string` | `""` | no |
| api\_gw\_500\_errors\_threshold | Maximum number of 500 errors (backend errors) on API GW requests allowed before sending an alarms | `string` | `""` | no |
| api\_gw\_alarm\_severity | Severity of the alarm triggered for API Gateway. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| api\_gw\_latency\_threshold | Maximum latency time in milliseconds on API GW requests allowed before sending an alarms | `string` | `""` | no |
| api\_gw\_names | Name of the API GW's to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| api\_gw\_rackspace\_alarms\_enabled | Specifies whether API GW alarms will create a Rackspace ticket | `bool` | `false` | no |
| app\_name | Name of the customer | `string` | n/a | yes |
| asg\_alarm\_severity | Severity of the alarm triggered for ASG. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| asg\_names | Names of ASG to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| asg\_rackspace\_alarms\_enabled | Specifies whether ASG alarms will create a Rackspace ticket | `bool` | `false` | no |
| asg\_terminated\_instances | Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm. | `string` | `"30"` | no |
| cloudfront\_500\_errors\_threshold | Maximum percentage of 500 errors (backend errors) on Cloudfront requests allowed before sending an alarms | `string` | `""` | no |
| cloudfront\_alarm\_severity | Severity of the alarm triggered for Cloudfront. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| cloudfront\_distribution\_ids | Cloudfront Id's to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| cloudfront\_rackspace\_alarms\_enabled | Specifies whether Cloudfront alarms will create a Rackspace ticket | `bool` | `false` | no |
| cloudfront\_total\_errors\_threshold | Maximum percentage of total errors on Cloudfront requests allowed before sending an alarms | `string` | `""` | no |
| cw\_namespace\_linux | Namespace for the custom metrics on Linux Instances | `string` | `"CWAgent"` | no |
| cw\_namespace\_windows | Namespace for the custom metrics on Windows Instances | `string` | `"CWAgent"` | no |
| ec2\_alarm\_severity | Severity of the alarm triggered for EC2. Can be emergency, urgent or standard | `string` | `"high"` | no |
| ec2\_cw\_cpu\_high\_evaluations | The number of periods over which data is compared to the specified threshold on EC2 alarm | `number` | `15` | no |
| ec2\_cw\_cpu\_high\_operator | Math operator used by CloudWatch for alarms and triggers on EC2 alarm | `string` | `"GreaterThanThreshold"` | no |
| ec2\_cw\_cpu\_high\_period | Time the specified statistic is applied on EC2 alarm. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| ec2\_cw\_cpu\_high\_threshold | The value against which the specified statistic is compared on EC2 alarm. | `number` | `90` | no |
| ec2\_disk\_linux\_threshold | Maximum EBS volume utilization before triggering an alarm. Only applies for Linux instances | `number` | `90` | no |
| ec2\_disk\_windows\_threshold | Minimum EBS volume utilization before triggering an alarm. Only applies for Windows instances | `number` | `10` | no |
| ec2\_instance\_ids | Identifiers of EC2 instance to monitor (don't include instances from ASG's). The list should match the length specified | `list(string)` | `[]` | no |
| ec2\_memory\_linux\_threshold | Maximum memory utilization before triggering an alarm. Only applies for Linux instances | `number` | `90` | no |
| ec2\_memory\_windows\_threshold | Minimum memory utilization before triggering an alarm. Only applies for Windows instances | `number` | `10` | no |
| ec2\_rackspace\_alarms\_enabled | Specifies whether EC2 alarms will create a Rackspace ticket | `bool` | `true` | no |
| ecs\_alarm\_severity | Severity of the alarm triggered for ECS. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| ecs\_cpu\_high\_threshold | The value against which the specified statistic is compared on ECS CPU alarm. | `number` | `75` | no |
| ecs\_memory\_high\_threshold | The value against which the specified statistic is compared on ECS memory alarm. | `number` | `75` | no |
| ecs\_rackspace\_alarms\_enabled | Specifies whether ECS alarms will create a Rackspace ticket | `bool` | `false` | no |
| ecs\_services\_list | Maps representing the ECS cluster/service combination. Example: [{cluster = 'cluster1', service = 'service1'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| elb\_alarm\_severity | Severity of the alarm triggered for ALB/NLB. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| elb\_rackspace\_alarms\_enabled | Specifies whether ELB alarms will create a Rackspace ticket | `bool` | `false` | no |
| enable\_recovery\_alarms | Boolean parameter controlling if auto-recovery alarms should be created.  Recovery actions are not supported on all instance types and AMIs, especially those with ephemeral storage.  This parameter should be set to false for those cases. | `bool` | `true` | no |
| lambda\_alarm\_severity | Severity of the alarm triggered for Lambda. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| lambda\_names | Name of the Lambda functions to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| lambda\_rackspace\_alarms\_enabled | Specifies whether Lambda alarms will create a Rackspace ticket | `bool` | `false` | no |
| lin\_disk\_list | Maps for the Linux instances including the device names associated to the volumes | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| lin\_mem\_list | List of Linux instances reporting memory metrics | `list(string)` | `[]` | no |
| nlb\_tg\_list | Maps representing NLB and Target Groups combinations to monitor. Example: [{nlb\_prefix = 'net/nlb-test/xxxxxxxxx', tg\_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| nlb\_unhealthy\_target\_threshold | The value against which the calculation of unhealthy hosts behind an NLB. If this value is empty, an alarm that detects any unhealthy host will be created | `string` | `""` | no |
| notification\_topic | The SNS topic to use for customer notifications. | `list(string)` | `[]` | no |
| number\_alb\_tg | Number of ALB's & Target group combinations to monitor. | `number` | `0` | no |
| number\_api\_gws | Number of API GW's to monitor | `number` | `0` | no |
| number\_asg | Number of AutoScaling Groups to monitor | `number` | `0` | no |
| number\_cloudfront\_distributions | Number of Cloudfront distributions to monitor | `number` | `0` | no |
| number\_ec2\_instances | Number of RDS instances to monitor (don't include instances from ASG's) | `number` | `0` | no |
| number\_ecs\_services | Number of ECS services per cluster to monitor | `number` | `0` | no |
| number\_lambda\_functions | Number of Lambda functions to monitor | `number` | `0` | no |
| number\_lin\_disk | Number of EBS volumes associated to Linux instances that are currently reporting metrics | `number` | `0` | no |
| number\_lin\_mem | Number of Linux instances currently with metrics related to memory usage | `number` | `0` | no |
| number\_nlb\_tg | Number of NLB's & Target group combinations to monitor. | `number` | `0` | no |
| number\_win\_disk | Number of EBS volumes associated to Windows instances that are currently reporting metrics | `number` | `0` | no |
| number\_win\_mem | Number of Windows instances currently with metrics related to memory usage | `number` | `0` | no |
| win\_disk\_list | Maps for the Windows instances including the device units associated to the volumes | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| win\_mem\_list | Maps for the Windows instances including the total available memory | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |

## Outputs

No output.

