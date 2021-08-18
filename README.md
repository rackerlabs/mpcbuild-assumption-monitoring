# mpcbuild-assumption-monitoring

This repository contain a solution to implement the monitoring & backup needed for assumptions. It is divided in layers to manage it according to BE Americas standard.

UPDATE: The module is being modified to be used for AMR builds, given that this the default new offering; it includes new alarms for a greater scope of services, such as Lambda, ECS, FSX, API GW & Cloudfront. It can still be used for remediations in legacy service blocks

## Module listing
- [base](./modules/000base/) - Terraform module for monitoring resources considered at base layer, including the possibility to deploy AWS backup
- [data](./modules/100data/) - Terraform module for monitoring resources considered at data layer
- [compute](./modules/200compute/) - Terraform module for monitoring resources considered at compute layer