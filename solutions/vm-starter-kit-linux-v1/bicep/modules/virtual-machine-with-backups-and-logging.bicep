targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vNetName string
param vmSubnetName string

param vmName string
param vmSize string
param osdiskSizeGB int
param ubuntuOffer string
param ubuntuSku string
param adminUsername string
@secure()
param sshPublicKey string

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
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: ubuntuOffer
        sku: ubuntuSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osdiskSizeGB
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

resource nginxExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'InstallNginx'
  parent: vm
  location: location
  properties:{
    publisher: 'Microsoft.Azure.Extensions'
    type:'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings:{
      commandToExecute: 'sudo apt-get update && sudo apt-get install nginx -y && sudo sed -i "s/Welcome to nginx/Welcome to nginx from the VM Starter Kit/g" /var/www/html/index.nginx-debian.html'
    }
  }
}

resource healthExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'HealthExtension'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.ManagedServices'
    type: 'ApplicationHealthLinux'
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
  dependsOn: [
    nginxExtension
  ]
}

resource dependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'DependencyAgentLinux'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
    settings: {
      enableAMA: true
    }
  }
  dependsOn: [
    nginxExtension
  ]
}

resource azureMonitorExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'AzureMonitorLinuxAgent'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
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
  dependsOn: [
    nginxExtension
  ]
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
