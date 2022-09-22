# Hub-spoke networking in Azure

Hub and spoke (hub-spoke or star) is a common industry networking topology that that is used for network-level isolation of resources while facilitating their required communication paths. The centralization of key networking resources, such as gateways and firewalls, helps you manage common security or cross-premises communication requirements. On your cloud adoption journey, you'll likely soon reach the point that the added structure and capabilities that this topology offers is worth investing in. Hub-spoke networks not only provide a common pattern and governance target, it can also help your organization perform cost optimization where centralized network services can be shared (and amortized) across multiple workloads and/or business units, minimizing redundant Azure resources and management effort.

![Hub-spoke topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/images/hub-spoke.png)

_Download a [Visio file](https://arch-center.azureedge.net/hub-spoke-network-topology-architecture.vsdx) of this architecture._

## Architecture

The solution deployed in this Azure Solution Center quickstart is based off of the [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) guidance found in the Azure Architecture Center. That reference architecture has additional details around spoke connectivity, peering, cross-premises connections, monitoring, and more.  Depending on what configuration you select in this Solution Center quickstart, you will get all of the above, or just a subset.

### Regionality and reliability

Hubs are usually managed as business-critical assets in organizations, as they could represent a common infrastructure spanning multiple workloads or business processes. Fundamentally, hubs are regional solutions. While all the components found in hubs (VPN Gateway and Azure Firewall) are highly available services, supporting Availability Zones and having SLAs, they would not survive a complete regional outage. This means that typically you'd expect to see one hub per region in which you need such network control. [Global peering](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview) or other such traffic routing solutions should be evaluated for reliability impact and other constraints.

### Azure resources deployed

The following Azure resources are deployed as part of this Solution Center quickstart. Every resource is configured to be zone redundant [where available](https://learn.microsoft.com/azure/availability-zones/az-region#highly-available-services) and to use Azure Diagnostics where available.

> ⏱️ Deployments take anywhere from about 10 to 40 minutes, depending on the configuration selected.

#### Configuration: Foundational deployment

| Resource | Quantity | SKU/Tier |
| -- | --:| -- |
| Virtual Networks | 3 | _Not applicable_ |
| Route Table | 1 | _Not applicable_ |
| Public IPs | 4 | Standard |
| Network Security Groups | 3 | _Not applicable_ |
| Log Analytics workspace | 1 | Pay-as-you-go |
| Azure Firewall | 1 | Standard |
| Azure Firewall Policy | 1 | Standard |
| Azure Bastion | 1 | Basic |

#### Configuration: Foundational deployment with VPN Gateway

| Resource | Quantity | SKU/Tier |
| -- | --:| -- |
| Virtual Networks | 3 | _Not applicable_ |
| Route Table | 1 | _Not applicable_ |
| Public IPs | 5 | Standard |
| Network Security Groups | 3 | _Not applicable_ |
| Log Analytics workspace | 1 | Pay-as-you-go |
| Azure Firewall | 1 | Standard |
| Azure Firewall Policy | 1 | Standard |
| Azure Bastion | 1 | Basic |
| Azure VPN Gateway | 1 | VpnGw2AZ |

#### Configuration: Foundational deployment with VPN Gateway and an example workload

| Resource | Quantity | SKU/Tier |
| -- | --:| -- |
| Virtual Networks | 3 | _Not applicable_ |
| Route Table | 1 | _Not applicable_ |
| Public IPs | 5 | Standard |
| Network Security Groups | 3 | _Not applicable_ |
| Log Analytics workspace | 1 | Pay-as-you-go |
| Azure Firewall | 1 | Standard |
| Azure Firewall Policy | 1 | Standard |
| Azure Bastion | 1 | Basic |
| Azure VPN Gateway | 1 | VpnGw2AZ |
| Azure Virtual Machine (Windows) | 1 | Standard D2s v3 |
| Virtual Machine Disk (Windows) | 1 | Premium SSD LRS |
| Azure Virtual Machine (Linux) | 1 | Standard D2ds v4 |
| VM Network Interfaces | 2 | Accelerated |

## Azure Virtual WAN

Azure Virtual WAN simplifies end-to-end network connectivity in Azure by providing hub, spoke connectivity, hub-to-hub, and cross-premises connectivity services. Hub-spoke architecture is the foundation of Azure Virtual WAN. This Azure Solution Center quickstart does not deploy using this managed service offering. See [Global transit network architecture and Virtual WAN](https://learn.microsoft.com/azure/virtual-wan/virtual-wan-global-transit-network-architecture) to learn more about how the service can simplify your organization's hubs.

## Azure landing zones

[Azure landing zone](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) is considered a north star architecture for many organizations. Hub-spoke networking is core to the [Network topology and connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity) design area. Hubs are typically managed by the platform team in a dedicated connectivity subscription, while spokes exist in the workload landing zone subscriptions. This pattern is more advanced than the configurations available in this Azure Solution Center quickstart, but the principles are similar.

To learn more about Azure landing zone hub-spoke topologies, see:

* [Traditional Azure networking topology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology)
* [Virtual WAN network topology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/virtual-wan-network-topology)

## Troubleshooting

### Azure Policy

This Azure Solution Center quickstart does not deploy any Azure Policies. If you run into policy violations, check to see what Azure Policies are applying to your resource group, there may be pre-existing policies in your subscription or management group hirarchy that could interfere with deployment.

### Resource quotas

Your subscription might have resource quotas applied to it that might prevent successful deployment of this quickstart.

## Related resources

* [Choose a networking architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/considerations/networking-options#choose-a-networking-architecture)
* [Azure Well-Architected Framework service guide for Azure Firewall](https://learn.microsoft.com/azure/architecture/framework/services/networking/azure-firewall)
* [Azure Well-Architected Framework service guide for ExpressRoute](https://learn.microsoft.com/azure/architecture/framework/services/networking/azure-expressroute)