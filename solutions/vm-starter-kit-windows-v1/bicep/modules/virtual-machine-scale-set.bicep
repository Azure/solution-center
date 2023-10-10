targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vmScaleSetName string

param vNetName string
param vmSubnetName string

param loggingStorageUri string

param vmNamePrefix string
param vmSize string
param windowsOffer string
param windowsSku string
param adminUsername string
@secure()
param adminPassword string

param loadBalancerName string
param loadBalancerBackendPoolName string

param managedIdentityResourceId string
param managedIdentityClientId string

resource vmScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: vmScaleSetName
  location: location
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: 3
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Flexible'
    platformFaultDomainCount: 1
    virtualMachineProfile: {
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: windowsOffer
          sku: windowsSku
          version: 'latest'
        }
        osDisk: {
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          caching: 'ReadWrite'
          createOption: 'FromImage'
        }
      }
      networkProfile: {
        networkApiVersion: '2020-11-01'
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNetName, vmSubnetName)
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerBackendPoolName)
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
      osProfile: {
        computerNamePrefix: vmNamePrefix
        adminUsername: adminUsername
        adminPassword: adminPassword
        windowsConfiguration: {
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'AutomaticByPlatform'
            enableHotpatching: true
            automaticByPlatformSettings: {
               bypassPlatformSafetyChecksOnUserSchedule: false
            }
          }
          enableAutomaticUpdates: true
        }
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
          storageUri: loggingStorageUri
        }
      }
      extensionProfile: {
        extensions: [
          {
            name: 'InstallIIS'
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
          {
            name: 'HealthExtension'
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
          {
            name: 'DependencyAgentWindows'
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
          {
            name: 'AzureMonitorWindowsAgent'
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
        ]
      }
    }
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
