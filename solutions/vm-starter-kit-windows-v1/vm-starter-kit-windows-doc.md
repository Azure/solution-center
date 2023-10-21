
<h2>VM Starter Kit Overview </h2>
 

The Virtual Machine (VM) Starter Kit provides a way to evaluate Azure Virtual Machines and complementary services by simplifying the deployment of Azure VMs configured with capabilities like remote management, monitoring, backup, availability, and scalability. 

You will find three deployment configurations in the VM Starter Kit that build upon each other and provide additional capabilities. The resources deployed by the starter kit are pre-defined and fixed, you just need to select the subscription you want to use, the resource group you want to deploy into, the region for your deployment, and provide the admin username and password you want to use to connect to your Virtual Machines if you are using Windows. If you are using Linux, provide the admin username and SSH key you want to use.  
 
The first configuration, referred to as “Get Connected”, is a minimalistic configuration that includes a Virtual Machine with the required supporting resources like a Virtual Network, network interface, and operating system (OS) disk. In addition to the Virtual Machine and it’s required supporting resources, Azure Bastion is deployed to enable secure remote management of your virtual machine.  

The second configuration, which is labeled “Backup & Monitoring” deploys everything in the "Get Connected” configuration and adds capabilities for improved management and monitoring using Azure Monitor and Azure Backup. 

The third and final configuration, "Availability & Scale” focuses on optimizing uptime and enabling you to respond to changes in demand for your workload. This configuration replaces the single Azure Virtual Machine resource with a Virtual Machine Scale Set which lets you simply create and manage a group of load-balanced VMs, while still providing the “Backup & Monitoring” features. 

<h2>Topology</h2> 

In each of the configurations, an Azure Virtual Network is created. The Azure Virtual Network is the foundational building block for private networking and network communication. The network is named vnet-VmStarterKit, has an IP address space of 10.1.0.0/16, and has two subnets defined, AzureBastionSubnet and VMs. The VMs that are created as part of the VM Starter Kit aren’t exposed to the public internet with a public IP address attached to the NIC of the VM. Instead, the VMs only have private IP addresses internal to the virtual network.  

<img src='https://raw.githubusercontent.com/Azure/solution-center/main/solutions/vm-starter-kit-windows-v1/networkdiagram.jpg'> 

In each of the configurations, the Azure resources and the naming of the resources are pre-defined, however, you can deploy and run any workload of your choice in the VMs that are deployed as part of the VM Starter Kit. The resources get deployed into your subscription and are in your control to adapt and customize as you need for your workload. For example, if you want to create additional subnets in your virtual network, you can do that.  

<H2>Cost Estimates and Cost Management </h2>

All the VM Starter Kit configurations can be deployed in an Azure free trial, but the length of time you will be able to have them deployed and running will depend on the Azure credits you have available. The following table provides an estimated cost for each of the configurations using the Azure pricing calculator. 


<table>
<tr>
<th>Configuration</th>
<th>Estimated Cost (Linux)</th>
<th>Estimated Cost (Windows)</th>
</tr>

<td>Get Connected</td>
<td>
$8/day

[Pricing Estimate](https://azure.com/e/682c697d6ccf43679b6b795bdb2a5326)

</td>
<td>
$11/day

[Pricing Estimate](https://azure.com/e/1d1109755b9947b6bdec32228827ccc1)
</td>
</tr>
<tr>
<td>Backup & Monitoring</td>
<td>
$12/day

[Pricing Estimate](https://azure.com/e/2603eb871ac24cad95b31f9727d195b6)
</td>
<td>
$14/day

[Pricing Estimate](https://azure.com/e/29c05db7c7c74b9ba310953fc180ddfb)</td>
</tr>
<tr>
<td>Availability & Scale</td>
<td>
$18/day

[Pricing Estimate](https://azure.com/e/c0bf3870b9914d458200e41fda886c36)</td>
<td>
$24/day

[Pricing Estimate](https://azure.com/e/e4f0d1aff6bc42f8a99df4755bfe8027)</td>
</tr>
</table>
 

Some services, like Azure Bastion and Managed Disks, have a metered cost based on the amount of time the resources are provisioned. Other services, like Azure Virtual Machines, have a metered cost based on the amount of time the resources are running. One approach you can take to optimize the cost of your Azure virtual machines is to shut them down and deallocate them when you aren’t using them. When you want to use them again, you can simply start them, and they will resume where you left off.  

<h2>Get Connected</h2> 

You can create an Azure Virtual Machine by clicking on the Create a resource button in the Azure portal, and that will guide you through creating a virtual machine and the supporting virtual network. You will also be able to attach a public IP address to your virtual machine, however, to securely connect and remotely manage the VMs, you need a jump box or bastion server. 

Azure Bastion is a bastion server and jump box as a service. This makes it possible to connect to your internally addressed virtual machines through a jump box without having to manage and secure the underlying infrastructure. The AzureBastionSubnet created in the virtual network is where Azure Bastion deploys the Azure Bastion host. 

The Get Connected configuration deploys the virtual network, subnets, virtual machine, and Azure Bastion to enable secure connectivity to your VM. The virtual machine network interface (NIC) is connected to the VMs subnet to enable network connectivity.  

<h2>Backup & Monitoring </h2>

You need to have reliable backups and visibility into the health and utilization of your infrastructure and solutions for your workloads to be production ready. The Backup & Monitoring configuration has everything in the Get Connected configuration, plus a Recovery Services vault to enable Azure Backup and a Log Analytics workspace for using VM Insights to monitor the health and performance of virtual machines.  

<h2>Availability & Scale </h2>

Typically, your workloads need to be resilient when hardware fails, be available even when you patch and update your solutions, and deliver consistent performance even when the load and demand on your workloads fluctuate. The Availability & Scale configuration has everything in the Get Connected configuration and the Backup & Monitoring configuration, but instead of using the Azure Virtual Machines service for compute and hosting your workload, it uses Virtual Machine Scale Sets.  

Azure Virtual Machine Scale Sets (VMSS) provides a set of VMs that are spread across racks of hardware and even datacenters in Azure. VMSS can also increase and decrease the number of VM instances that are part of the scale set to respond to the demand on your workload. These capabilities help you achieve the goals of availability and scale. 

Because of the dynamic nature of the number of VMs in the VMSS from scaling the instances, configuring the individual VMs including the agents that enable Azure Backup and Azure Monitor can’t happen when the Azure resources are initially deployed. As a result, in the Availability & Scale configuration, Azure Policy is used to configure these agents and VM instance configurations. 

While the VMs in the Availability & Scale configuration don’t have public IP addresses directly attached, in this configuration, a web server gets installed on each of the VMs and requests are directed to each of the VMs in the VMSS via an Azure Load Balancer. Managing the VMs remotely still needs to be done connecting with Azure Bastion but browsing the web server via port 80 (HTTP) or port 443 (HTTPS) will go through the load balancer. The Azure Load Balancer also has a public IP address attached to it so that the web server is accessible publicly.  

<h2>Deleting the VM Starter Kit solution in your Azure subscription </h2>

Once you are finished evaluating or using the VM Starter Kit solution that was deployed to your Azure subscription, you will likely want to delete the resources created by the VM Starter Kit. To delete the resources, you simply need to delete the resource group that you chose to deploy the VM Starter Kit into. Because of retention policies and the soft-delete configuration on Azure Backup, your resource group will be left with the Recovery Services vault in your subscription until the soft-delete restriction has expired.