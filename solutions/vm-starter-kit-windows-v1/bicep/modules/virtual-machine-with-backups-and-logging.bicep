targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vNetName string
param vmSubnetName string 

param vmName string
param vmSize string
param windowsOffer string
param windowsSku string
param adminUsername string
@secure()
param adminPassword string

param bootLogStorageAccountName string
param bootLogStorageAccountResourceGroup string = resourceGroup().name

param recoveryServicesVaultName string
var recoveryVaultPolicyName = 'DefaultPolicy'

param dataCollectionRuleName string
param managedIdentityResourceId string
param managedIdentityClientId string

param logAnalyticsWorkspaceId string

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNetName, vmSubnetName)
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: bootLogStorageAccountName
  scope: resourceGroup(bootLogStorageAccountResourceGroup)
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          enableHotpatching: true
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: windowsOffer
        sku: windowsSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource iisExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'InstallIIS'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
    }
  }
}

resource dependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'HealthExtension'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.ManagedServices'
    type: 'ApplicationHealthWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      protocol: 'http'
      port: 80
      requestPath: '/'
      intervalInSeconds: 5
      numberOfProbes: 1
    }
  }
}

resource dependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'DependencyAgentWindows'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
    settings: {
      enableAMA: true
    }
  }
}

resource azureMonitorExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'AzureMonitorWindowsAgent'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'client_id'
          'identifier-value': managedIdentityClientId
        }
      }
    }
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2021-04-01' existing = {
  name: dataCollectionRuleName
}

resource dataCollectionRuleAssociation 'Microsoft.Compute/virtualMachines/providers/dataCollectionRuleAssociations@2019-11-01-preview' = {
  name: '${vm.name}/Microsoft.Insights/VMInsights-Dcr-Association'
  properties: {
    description: 'Association of data collection rule for VM Insights.'
    dataCollectionRuleId: dataCollectionRule.id
  }
}

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2022-10-01' existing = {
  name: recoveryServicesVaultName
}

resource recoveryVaultPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-04-01' existing = {
  name: recoveryVaultPolicyName
  parent: recoveryVault
}

var backupProtectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
var backupProtectedItemName = 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'

resource backupProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-04-01' = {
  name: '${recoveryVault.name}/Azure/${backupProtectionContainer}/${backupProtectedItemName}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: recoveryVaultPolicy.id
    sourceResourceId: vm.id
    friendlyName: vm.name
  }
}

resource nicDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${nic.name}-diagnosticsettings'
  scope: nic
  properties: {
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}
