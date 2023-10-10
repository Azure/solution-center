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

param recoveryServicesVaultName string = 'rsv-VmBackupVault'

module vNetModule 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    networkName: networkName
    vmSubnetName: vmSubnetName
    logAnalyticsWorkspaceId: monitoringModule.outputs.logAnalyticsWorkspaceId
  }
}

module bastionModule 'modules/bastion.bicep' = {
  name: 'bastion'
  params: {
    location: location
    bastionName: bastionName
    vNetName: vNetModule.outputs.vNetName
    bastionSubnetName: vNetModule.outputs.bastionSubnetName
    logAnalyticsWorkspaceId: monitoringModule.outputs.logAnalyticsWorkspaceId
  }
}

module monitoringModule 'modules/monitoring-infrastructure.bicep' = {
  name: 'monitoring-infrastructure'
  params: {
    location: location
  }
}

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: recoveryServicesVaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

module vm 'modules/virtual-machine-with-backups-and-logging.bicep' = {
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
    bootLogStorageAccountName: monitoringModule.outputs.storageAccountName
    recoveryServicesVaultName: recoveryVault.name
    dataCollectionRuleName: monitoringModule.outputs.dataCollectionRuleName
    managedIdentityResourceId: monitoringModule.outputs.managedIdentityResourceId
    managedIdentityClientId: monitoringModule.outputs.managedIdentityClientId
    logAnalyticsWorkspaceId: monitoringModule.outputs.logAnalyticsWorkspaceId
  }
}

resource recoverySvcsVaultDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${recoveryVault.name}-diagnosticsettings'
  scope: recoveryVault
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: monitoringModule.outputs.logAnalyticsWorkspaceId
  }
}
