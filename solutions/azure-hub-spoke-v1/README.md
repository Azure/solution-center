# Azure Hub-Spoke Solution

TODO

## Inventory

### Configuration

* [discovery.metadata.json](./configuration.metadata.json)
* [configuration.metadata.json](./configuration.metadata.json)

### ARM Templates

These ARM templates are generated from the Azure Architecture Center's hub-spoke ARM template and should generally stay in sync with them.  The source bicep file is found at <https://github.com/mspnp/samples/tree/main/solutions/azure-hub-spoke/bicep>.  That file contains all three varients, and undergoes a minor modification to break them into three seperate files, and then are converted to ARM json.

| File | Summary |
| ---- | ------- |
| [base.json](./base.json) | The basic/empty deployment. |
| [base_with_resources.json](./base_with_resources.json) | Adds VM resources to the basic/empty deployment. |
| [base_with_resources_and_vpn_gateway.json](./base_with_resources_and_vpn_gateway.json) | Adss VM resources & VPN Gateway to the basic/empty deployment. |

### Documentation

* [hub-spoke-overview.md](./hub-spoke-overview.md)