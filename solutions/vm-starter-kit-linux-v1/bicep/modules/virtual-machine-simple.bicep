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

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
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
  }
}
