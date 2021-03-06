## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alb\_response\_time\_threshold | The value against which the specified statistic is compared on ALB response time alarm | `string` | `"10"` | no |
| alb\_tg\_list | Maps representing ALB and Target Groups combinations to monitor. Example: [{alb\_prefix = 'app/alb-test/xxxxxxxxx', tg\_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| app\_name | Name of the customer | `string` | n/a | yes |
| asg\_cw\_high\_evaluations | The number of periods over which data is compared to the specified threshold. | `string` | `"3"` | no |
| asg\_cw\_high\_operator | Math operator used by CloudWatch for alarms and triggers on ASG (high threshold). | `string` | `"GreaterThanThreshold"` | no |
| asg\_cw\_high\_period | Time the specified statistic is applied on ASG (high threshold). Must be in seconds that is also a multiple of 60. | `string` | `"60"` | no |
| asg\_cw\_high\_threshold | The value against which the specified statistic is compared on ASG (high threshold). | `string` | `"60"` | no |
| asg\_cw\_low\_evaluations | The number of periods over which data is compared to the specified threshold on ASG (low). | `string` | `"3"` | no |
| asg\_cw\_low\_operator | Math operator used by CloudWatch for alarms and triggers on ASG (low threshold). | `string` | `"LessThanThreshold"` | no |
| asg\_cw\_low\_period | Time the specified statistic is applied on ASG (low threshold). Must be in seconds that is also a multiple of 60. | `string` | `"300"` | no |
| asg\_cw\_low\_threshold | The value against which the specified statistic is compared on ASG (low threshold). | `string` | `"30"` | no |
| asg\_cw\_scaling\_metric | The metric to be used for scaling on ASG. | `string` | `"CPUUtilization"` | no |
| asg\_ec2\_scale\_down\_adjustment | Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative. | `string` | `"-1"` | no |
| asg\_ec2\_scale\_down\_cool\_down | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| asg\_ec2\_scale\_up\_adjustment | Number of EC2 instances to scale up by at a time. | `string` | `"1"` | no |
| asg\_ec2\_scale\_up\_cool\_down | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| asg\_enable\_scaling\_actions | Should this autoscaling group be configured with scaling alarms to manage the desired count.  Set this variable to false if another process will manage the desired count, such as EKS Cluster Autoscaler. | `bool` | `false` | no |
| asg\_names | Names of ASG to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| asg\_rackspace\_alarms\_enabled | Specifies whether ASG alarms will create a Rackspace ticket | `bool` | `false` | no |
| asg\_terminated\_instances | Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm. | `string` | `"30"` | no |
| ec2\_cw\_cpu\_high\_evaluations | The number of periods over which data is compared to the specified threshold on EC2 alarm | `number` | `15` | no |
| ec2\_cw\_cpu\_high\_operator | Math operator used by CloudWatch for alarms and triggers on EC2 alarm | `string` | `"GreaterThanThreshold"` | no |
| ec2\_cw\_cpu\_high\_period | Time the specified statistic is applied on EC2 alarm. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| ec2\_cw\_cpu\_high\_threshold | The value against which the specified statistic is compared on EC2 alarm. | `number` | `90` | no |
| ec2\_instance\_ids | Identifiers of EC2 instance to monitor (don't include instances from ASG's). The list should match the length specified | `list(string)` | `[]` | no |
| ec2\_rackspace\_alarms\_enabled | Specifies whether EC2 alarms will create a Rackspace ticket | `bool` | `true` | no |
| ecs\_cpu\_high\_threshold | The value against which the specified statistic is compared on ECS CPU alarm. | `number` | `75` | no |
| ecs\_memory\_high\_threshold | The value against which the specified statistic is compared on ECS memory alarm. | `number` | `75` | no |
| ecs\_rackspace\_alarms\_enabled | Specifies whether ECS alarms will create a Rackspace ticket | `bool` | `false` | no |
| ecs\_services\_list | Maps representing the ECS cluster/service combination. Example: [{cluster = 'cluster1', service = 'service1'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| elb\_rackspace\_alarms\_enabled | Specifies whether ELB alarms will create a Rackspace ticket | `bool` | `false` | no |
| enable\_recovery\_alarms | Boolean parameter controlling if auto-recovery alarms should be created.  Recovery actions are not supported on all instance types and AMIs, especially those with ephemeral storage.  This parameter should be set to false for those cases. | `bool` | `true` | no |
| lambda\_names | Name of the Lambda functions to monitor | `list(string)` | `[]` | no |
| lambda\_rackspace\_alarms\_enabled | Specifies whether ECS alarms will create a Rackspace ticket | `bool` | `false` | no |
| nlb\_tg\_list | Maps representing NLB and Target Groups combinations to monitor. Example: [{nlb\_prefix = 'net/nlb-test/xxxxxxxxx', tg\_prefix = 'targetgroup/tg-test/xxxxxxxxx'}]. | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| notification\_topic | The SNS topic to use for customer notifications. | `list(string)` | `[]` | no |
| number\_alb\_tg | Number of ALB's & Target group combinations to monitor. | `number` | `0` | no |
| number\_asg | Number of AutoScaling Groups to monitor | `number` | `0` | no |
| number\_ec2\_instances | Number of RDS instances to monitor (don't include instances from ASG's) | `number` | `0` | no |
| number\_ecs\_services | Number of ECS services per cluster to monitor | `number` | `0` | no |
| number\_lambda\_functions | Number of Lambda functions to monitor | `number` | `0` | no |
| number\_nlb\_tg | Number of NLB's & Target group combinations to monitor. | `number` | `0` | no |

## Outputs

No output.

