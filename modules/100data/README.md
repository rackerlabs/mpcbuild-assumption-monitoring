## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| app\_name | Name of the customer | `string` | n/a | yes |
| aurora\_alarm\_cpu\_limit | CloudWatch CPUUtilization Threshold for Aurora | `number` | `75` | no |
| aurora\_alarm\_severity | Severity of the alarm triggered for Aurora. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| aurora\_free\_memory\_threshold | Minimum percentage of freeable memory on Aurora before triggering an alarm | `number` | `10` | no |
| aurora\_nodes | Identifiers for all Aurora nodes (writer and reader nodes) to monitor, including a size identifier. The list should match the length specified | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| aurora\_rackspace\_alarms\_enabled | Specifies whether Aurora alarms will create a Rackspace ticket. | `bool` | `true` | no |
| aurora\_read\_latency\_threshold | Maximum time in seconds of latency in read operations on Aurora before triggering an alarm | `string` | `""` | no |
| aurora\_readers\_identifiers | List of identifiers for Aurora reader nodes | `list(string)` | `[]` | no |
| aurora\_replica\_lag\_threshold | Maximum lag in milliseconds allowed before triggering an alarm | `number` | `10000` | no |
| aurora\_write\_latency\_threshold | Maximum time in seconds of latency in write operations on Aurora before triggering an alarm | `string` | `""` | no |
| dynamo\_alarm\_severity | Severity of the alarm triggered for DynamoDB. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| dynamo\_rackspace\_alarms\_enabled | Specifies whether Dynamo alarms will create a Rackspace ticket. | `bool` | `true` | no |
| dynamo\_read\_throttling\_threshold | Number of read throttling events on DynamoDB that will trigger an alarm | `string` | `""` | no |
| dynamo\_tables | Identifiers of DynamoDB tables to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| dynamo\_write\_throttling\_threshold | Number of write throttling events on DynamoDB that will trigger an alarm | `string` | `""` | no |
| efs\_alarm\_severity | Severity of the alarm triggered for EFS. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| efs\_connections\_threshold | Number of connections on EFS allowed before triggering an alarm | `string` | `""` | no |
| efs\_rackspace\_alarms\_enabled | Specifies whether EFS alarms will create a Rackspace ticket. | `bool` | `true` | no |
| efs\_throughput\_percent\_threshold | Percentage of permitted throughput used on EFS before triggering an alarm | `number` | `80` | no |
| elastic\_filesystem\_ids | Identifiers of EFS to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| fsx\_alarm\_severity | Severity of the alarm triggered for FSX. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| fsx\_free\_space\_threshold | Free Storage Space Limit Threshold (Bytes) for FSX | `string` | `""` | no |
| fsx\_ids | Identifiers of FSX filesystems to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| fsx\_rackspace\_alarms\_enabled | Specifies whether FSX alarms will create a Rackspace ticket. | `bool` | `true` | no |
| notification\_topic | The SNS topic to use for customer notifications. | `list(string)` | `[]` | no |
| number\_aurora\_nodes | Number of Aurora Nodes (writer and reader nodes) to monitor | `number` | `0` | no |
| number\_aurora\_readers | Number of Aurora nodes acting as reader nodes | `number` | `0` | no |
| number\_dynamo\_tables | Number of provisioned DynamoDB tables | `number` | `0` | no |
| number\_elastic\_filesystems | Number of EFS to monitor | `number` | `0` | no |
| number\_fsx\_filesystems | Number of FSX filesystems to monitor | `number` | `0` | no |
| number\_rds\_instances | Number of RDS instances to monitor (without read replicas) | `number` | `0` | no |
| number\_rds\_read\_replicas | Number of RDS read replicas to monitor | `number` | `0` | no |
| number\_redis\_clusters | Number of Redis clusters to monitor | `number` | `0` | no |
| number\_redshift\_nodes | Number of Redshift nodes to monitor | `number` | `0` | no |
| rds\_alarm\_cpu\_limit | CloudWatch CPUUtilization Threshold for RDS | `number` | `75` | no |
| rds\_alarm\_free\_space\_threshold | Minimum percentage of Free Storage Space for RDS before triggering an alarm | `number` | `10` | no |
| rds\_alarm\_read\_iops\_limit | CloudWatch Read IOPSLimit Threshold for RDS | `number` | `100` | no |
| rds\_alarm\_severity | Severity of the alarm triggered for RDS. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| rds\_alarm\_write\_iops\_limit | CloudWatch Write IOPSLimit Threshold for RDS | `number` | `100` | no |
| rds\_depth\_queue\_threshold | RDS depth queue limit for an alarm | `string` | `""` | no |
| rds\_instances\_list | Maps including the RDS instance identifier and the storage allocated | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| rds\_rackspace\_alarms\_enabled | Specifies whether RDS alarms will create a Rackspace ticket. | `bool` | `true` | no |
| rds\_read\_latency\_threshold | RDS read latency limit for an alarm | `string` | `""` | no |
| rds\_replica\_lag\_threshold | Maximum lag in seconds allowed before triggering an alarm | `number` | `600` | no |
| rds\_replicas\_list | Maps including the RDS instance identifier of the replica and the storage allocated | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| rds\_write\_latency\_threshold | RDS write latency limit for an alarm | `string` | `""` | no |
| redis\_alarm\_severity | Severity of the alarm triggered for Elasticache Redis. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| redis\_cluster\_ids | Identifiers of Redis clusters to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| redis\_cpu\_high\_evaluations | (redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_cpu\_high\_threshold | (redis) The max CPU Usage % before generating an alarm. | `number` | `75` | no |
| redis\_memory\_high\_evaluations | (redis) The number of minutes memory usage must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| redis\_memory\_high\_threshold | (redis) The max memory usage % before generating an alarm. | `number` | `75` | no |
| redis\_rackspace\_alarms\_enabled | Specifies whether Redis (Elasticache) alarms will create a Rackspace ticket. | `bool` | `true` | no |
| redshift\_alarm\_severity | Severity of the alarm triggered for Redshift. Can be emergency, urgent or standard | `string` | `"urgent"` | no |
| redshift\_cw\_cpu\_threshold | CloudWatch CPUUtilization Threshold for Redshift | `number` | `90` | no |
| redshift\_cw\_percentage\_disk\_used | CloudWatch Percentage of storage consumed threshold for Redshift | `number` | `90` | no |
| redshift\_nodes\_ids | Identifiers of Redshift nodes to monitor. The list should match the length specified | `list(string)` | `[]` | no |
| redshift\_rackspace\_alarms\_enabled | Specifies whether Redshift alarms will create a Rackspace ticket. | `bool` | `true` | no |

## Outputs

No output.

