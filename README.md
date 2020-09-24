# mpcbuild-assumption-monitoring

This repository contain a solution to implement the monitoring needed for assumptions. It is divided in layers to manage it according to BE Americas standard.

## Module listing
- [base](./modules/000base/) - Terraform module for monitoring resources considered at base layer, including the possibility to deploy AWS backup
- [data](./modules/100data/) - Terraform module for monitoring resources considered at data layer
- [compute](./modules/200compute/) - Terraform module for monitoring resources considered at compute layer