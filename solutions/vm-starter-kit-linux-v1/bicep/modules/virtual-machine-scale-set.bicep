targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vmScaleSetName string

param vNetName string
param vmSubnetName string

param loggingStorageUri string

param vmNamePrefix string
param vmSize string
param ubuntuOffer string
param ubuntuSku string
param adminUsername string
@secure()
param sshPublicKey string
param osdiskSizeGB int

param loadBalancerName string
param loadBalancerBackendPoolName string

param managedIdentityResourceId string
param managedIdentityClientId string

resource vmScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2022-08-01' = {
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
    // upgradePolicy: {
    //   mode: 'Rolling'
    // }
    virtualMachineProfile: {
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: ubuntuOffer
          sku: ubuntuSku
          version: 'latest'
        }
        osDisk: {
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          caching: 'ReadWrite'
          createOption: 'FromImage'
          diskSizeGB: osdiskSizeGB
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
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'AutomaticByPlatform'
          }
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
            name: 'InstallNginx'
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
          {
            name: 'HealthExtension'
            properties: {
              provisionAfterExtensions: [
                'InstallNginx'
              ]
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
          }
          {
            name: 'DependencyAgentLinux'
            properties: {
              provisionAfterExtensions: [
                'InstallNginx'
              ]
              publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
              type: 'DependencyAgentLinux'
              typeHandlerVersion: '9.5'
              autoUpgradeMinorVersion: true
              settings: {
                enableAMA: true
              }
            }
          }
          {
            name: 'AzureMonitorLinuxAgent'
            properties: {
              provisionAfterExtensions: [
                'InstallNginx'
              ]
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
