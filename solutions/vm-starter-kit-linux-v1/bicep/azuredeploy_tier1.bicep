targetScope = 'resourceGroup'

param location string = resourceGroup().location

param bastionName string = 'BastionHost'
param networkName string = 'VmStarterKit'
param vmSubnetName string = 'VMs'

param vmName string = 'vm-01'
param vmSize string = 'Standard_D2s_v5'
param ubuntuOffer string = '0001-com-ubuntu-server-focal'
param ubuntuSku string = '20_04-lts-gen2'
param adminUsername string
@secure()
param sshPublicKey string
param osdiskSizeGB int = 30

module vNetModule 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    networkName: networkName
    vmSubnetName: vmSubnetName
  }
}

module bastionModule 'modules/bastion.bicep' = {
  name: 'bastion'
  params: {
    location: location
    bastionName: bastionName
    vNetName: vNetModule.outputs.vNetName
    bastionSubnetName: vNetModule.outputs.bastionSubnetName
  }
}

module VM 'modules/virtual-machine-simple.bicep' = {
  name: 'virtual-machine-${vmName}'
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    vmSize: vmSize
    osdiskSizeGB: osdiskSizeGB
    ubuntuOffer: ubuntuOffer
    ubuntuSku: ubuntuSku
    vNetName: vNetModule.outputs.vNetName
    vmSubnetName: vmSubnetName
  }
}
