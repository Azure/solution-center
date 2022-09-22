# Azure Hub-Spoke Solution Center solution

This directory contains the configuration and assets for the hub-spoke networking solution center solution.

## Configuration

* [discovery.metadata.json](./configuration.metadata.json)
* [configuration.metadata.json](./configuration.metadata.json)

## ARM Templates

These ARM templates are generated from the Azure Architecture Center's hub-spoke ARM template and should generally stay in sync with them. The source bicep file is found at <https://github.com/mspnp/samples/tree/main/solutions/azure-hub-spoke/bicep>. That file contains all three variants, and undergoes a minor modification to break them into three separate files, and then are converted to ARM JSON.

| File | Summary |
| ---- | ------- |
| [base.json](./base.json) | The basic/empty deployment. |
| [baseWithGateway.json](./baseWithGateway.json) | Adds VPN Gateway to the base deployment. |
| [baseWithGatewayAndCompute.json](./baseWithGatewayAndCompute.json) | Adds VPN Gateway & VM resources to the base deployment. |
| [bicep](./bicep/) | Contains the three ARM Bicep files that the ARM JSON files were generated from. |

## Documentation

* [hub-spoke-overview.md](./hub-spoke-overview.md)