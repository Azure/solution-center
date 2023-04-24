# Deploy and Manage a modern web solution with Azure SQL MI

This deploys a modern web solution with Azure SQL Managed Instance, together with a frontend VM, Azure Key Vault (AKV) and an optional Failover Groups for Azure SQL MI.

While you can use an Azure free account to get started, depending on the configuration you choose you will likely be required to upgrade to a paid account.

## Predefined deployment options

Below are a list of pre-defined/restricted deployment options based on typical deployment scenarios (i.e. dev/test, production etc.) All configurations are fixed and you just need to pass your administrator name and password for logging in to the deployed VMs and Azure SQL Managed Instances (the credentials will be shared and we urge you to change/customize them after deployment). Please note that the actual cost will be bigger with potentially auto-scaled VMs, backups and network cost.

| Configuration | Estimated Cost | 
| --- | --- | 
| Dev/Test  | [link](https://azure.com/e/e2a7174f8459473dad9ae0914a759b3e)|
| Small to Mid-Size | [link](https://azure.com/e/483df22b299e4e529d4ace3436f1401c)|
| Full Production Workload |[link](https://azure.com/e/a9660539f1f34e448ffe642954366e7a)|