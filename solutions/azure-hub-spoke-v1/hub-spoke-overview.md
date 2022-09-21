# Hub-spoke networking in Azure

Hub and spoke (hub-spoke or star) is a common industry networking topology that that is used for network-level isolation of resources while facilitating their required communication paths. The centralization of key networking resources, such as gateways and firewalls, help you manage common security or cross-premises communication requirements. On your cloud adoption journey, you'll likely soon reach the point that the added structure and capabilities that this topology offers is worth investing in. Hub-spoke networks not only provide a common pattern and governance target, it can also help your organization perform cost optimization where centralized network services can be shared (and amortorized) across multiple workloads and/or business units, minimizing redundant Azure resources and management effort.

![Hub-spoke topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/images/hub-spoke.png)

_Download a [Visio file](https://arch-center.azureedge.net/hub-spoke-network-topology-architecture.vsdx) of this architecture._

## Architecture

The solution deployed in this Azure Solution Center quick start is based off of the [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) guidance found in the Azure Architecture Center. That reference architecture goes has additional details around spoke connectivity, peering, cross-premises connections, monitoring, and more.

### Regionality and reliability

Hubs are usually managed as business-critical assets in organizations, as they could represent a common infastructure spanning multiple workloads or business process. Fundimentally, hubs are regional solutions. While all the components found in hubs (VPN Gateway and Azure Firewall) are highly available services, supporting Availability Zones and having SLAs, they would not inherity survive a regional outage. This means that typically you'd expect to see one hub per region in which you need such network control. [Global peering](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview) or other such traffic routing solutions should be evaulated for reliability impact and other constraints.

## Azure Virtual WAN

Azure Virtual WAN simplifies end-to-end network connectivity in Azure by providing hub, spoke connectivity, hub-to-hub, and cross-premisis connectity services. Hub-spoke architecture is the foundation of Azure Virtual WAN. This Azure Solution Center quick start does not deploy using this managed service offering. See [Global transit network architecture and Virtual WAN](https://learn.microsoft.com/azure/virtual-wan/virtual-wan-global-transit-network-architecture) to learn more about how the service can simplify your organization's hubs.

## Azure landing zones

[Azure landing zone](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) is considered a north star architecture for many organizations. Hub-spoke networking is core to the [Network topology and connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity) design area of the architecture. Hubs are typically managed by the platform team in the Connectivty subscription, while spokes are allocated by the platform team, but exist in the workload landing zone subscriptions. This pattern is more advanced then the configurations available in this Azure Solution Center quick start.

Azure landing zone hub-spoke topologies:

* [Traditional Azure networking topology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology)
* [Virtual WAN network topology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/virtual-wan-network-topology)

## Related resources

* [Azure Well-Architected Framework service guide for Azure Firewall](https://learn.microsoft.com/azure/architecture/framework/services/networking/azure-firewall)
* [Azure Well-Architected Framework service guide for ExpressRoute](https://learn.microsoft.com/azure/architecture/framework/services/networking/azure-expressroute)