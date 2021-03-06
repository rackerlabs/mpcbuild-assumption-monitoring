## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| app\_name | Name of the customer | `string` | n/a | yes |
| aurora\_alarm\_cpu\_limit | CloudWatch CPUUtilization Threshold for Aurora | `number` | `60` | no |
| aurora\_alarm\_read\_io\_limit | CloudWatch Read IOPSLimit Threshold for Aurora | `number` | `60` | no |
| aurora\_alarm\_write\_io\_limit | CloudWatch Write IOPSLimit Threshold for Aurora | `number` | `100000` | no |
| aurora\_clusters | Maps representing Aurora Clusters to monitor. Example: [{cluster\_id = 'aurora-test', engine = 'aurora-mysql'}]. The nodes will be handled in another parameter | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| aurora\_nodes | Identifiers for all Aurora nodes (writer and reader nodes) to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| aurora\_rackspace\_alarms\_enabled | Specifies whether Aurora alarms will create a Rackspace ticket. | `bool` | `false` | no |
| efs\_cw\_burst\_credit\_period | The number of periods over which the EFS Burst Credit level is compared to the specified threshold. | `number` | `12` | no |
| efs\_cw\_burst\_credit\_threshold | The minimum EFS Burst Credit level before generating an alarm. | `number` | `1000000000000` | no |
| efs\_rackspace\_alarms\_enabled | Specifies whether EFS alarms will create a Rackspace ticket. | `bool` | `false` | no |
| elastic\_filesystem\_ids | Identifiers of EFS to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| notification\_topic | The SNS topic to use for customer notifications. | `list(string)` | `[]` | no |
| number\_aurora\_clusters | Number of Aurora Cluster to monitor | `number` | `0` | no |
| number\_aurora\_nodes | Number of Aurora Nodes (writer and reader nodes) to monitor | `number` | `0` | no |
| number\_elastic\_filesystems | Number of EFS to monitor | `number` | `0` | no |
| number\_rds\_instances | Number of RDS instances to monitor (without read replicas) | `number` | `0` | no |
| number\_rds\_read\_replicas | Number of RDS read replicas to monitor | `number` | `0` | no |
| number\_redis\_clusters | Number of Redis clusters to monitor | `number` | `0` | no |
| number\_redshift\_nodes | Number of EFS to monitor | `number` | `0` | no |
| rds\_alarm\_cpu\_limit | CloudWatch CPUUtilization Threshold for RDS | `number` | `75` | no |
| rds\_alarm\_free\_space\_limit | CloudWatch Free Storage Space Limit Threshold (Bytes) for RDS | `number` | `1024000000` | no |
| rds\_alarm\_read\_iops\_limit | CloudWatch Read IOPSLimit Threshold for RDS | `number` | `100` | no |
| rds\_alarm\_write\_iops\_limit | CloudWatch Write IOPSLimit Threshold for RDS | `number` | `100` | no |
| rds\_depth\_queue\_threshold | RDS depth queue limit for an alarm | `string` | `""` | no |
| rds\_instance\_identifiers | Identifiers of RDS instance to monitor (without read replicas). The list should match the length specified | `list(string)` | `[]` | no |
| rds\_rackspace\_alarms\_enabled | Specifies whether RDS alarms will create a Rackspace ticket. | `bool` | `false` | no |
| rds\_read\_latency\_threshold | RDS read latency limit for an alarm | `string` | `""` | no |
| rds\_write\_latency\_threshold | RDS write latency limit for an alarm | `string` | `""` | no |
| read\_replicas\_identifiers | Identifiers of RDS read replicas to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| redis\_cluster\_ids | Identifiers of Redis clusters to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| redis\_cpu\_high\_evaluations | (redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_cpu\_high\_threshold | (redis) The max CPU Usage % before generating an alarm. | `number` | `75` | no |
| redis\_curr\_connections\_evaluations | (redis) The number of minutes current connections must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_curr\_connections\_threshold | (redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned. | `string` | `""` | no |
| redis\_evictions\_evaluations | (redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_evictions\_threshold | (redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned. | `string` | `""` | no |
| redis\_memory\_high\_evaluations | (redis) The number of minutes memory usage must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_memory\_high\_threshold | (redis) The max memory usage % before generating an alarm. | `number` | `75` | no |
| redis\_rackspace\_alarms\_enabled | Specifies whether Redis (Elasticache) alarms will create a Rackspace ticket. | `bool` | `false` | no |
| redshift\_cw\_cpu\_threshold | CloudWatch CPUUtilization Threshold for Redshift | `number` | `90` | no |
| redshift\_cw\_percentage\_disk\_used | CloudWatch Percentage of storage consumed threshold for Redshift | `number` | `90` | no |
| redshift\_nodes\_ids | Identifiers of Redshift nodes to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| redshift\_rackspace\_alarms\_enabled | Specifies whether Redshift alarms will create a Rackspace ticket. | `bool` | `false` | no |

## Outputs

No output.

