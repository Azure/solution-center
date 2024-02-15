param vmName string
param vmSize string = 'Standard_B1s'
param adminUsername string
param adminPassword securestring

var location = resourceGroup().location
var publisher = 'Canonical'
var offer = 'UbuntuServer'
var sku = '16.04-LTS'
var vmReference = 'Microsoft.Compute/virtualMachines/${vmName}'
var nicName = '${vmName}-nic'
var publicIPAddressName = '${vmName}-ip'
var publicIPAddressType = 'Dynamic'
var publicIPAddressSku = 'Basic'
var vnetName = '${vmName}-vnet'
var vnetAddressPrefix = '10.0.0.0/16'
var subnetName = '${vmName}-subnet'
var subnetAddressPrefix = '10.0.0.0/24'
var storageAccountName = uniqueString(resourceGroup().id) + 'sa'
var storageAccountType = 'Standard_LRS'
var osDiskName = '${vmName}-osdisk'
var osDiskVhdUri = 'https://' + storageAccountName + '.blob.core.windows.net/vhds/${vmName}-osdisk.vhd'
var imageReference = {
    publisher: publisher
    offer: offer
    sku: sku
    version: 'latest'
}
var nicId = resourceId('Microsoft.Network/networkInterfaces', nicName)
var publicIPAddressId = resourceId('Microsoft.Network/publicIPAddresses', publicIPAddressName)
var vnetId = resourceId('Microsoft.Network/virtualNetworks', vnetName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
    name: publicIPAddressName
    location: location
    sku: {
        name: publicIPAddressSku
    }
    properties: {
        publicIPAllocationMethod: publicIPAddressType
    }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                vnetAddressPrefix
            ]
        }
        subnets: [
            {
                name: subnetName
                properties: {
                    addressPrefix: subnetAddressPrefix
                }
            }
        ]
    }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
    name: nicName
    location: location
    dependsOn: [
        publicIPAddress
        virtualNetwork
    ]
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: publicIPAddressId
                    }
                    subnet: {
                        id: subnetRef
                    }
                }
            }
        ]
    }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
    name: vmName
    location: location
    dependsOn: [
        networkInterface
    ]
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        storageProfile: {
            osDisk: {
                name: osDiskName
                createOption: 'FromImage'
                caching: 'ReadWrite'
                managedDisk: {
                    storageAccountType: storageAccountType
                }
                osType: 'Linux'
                diskSizeGB: 30
                vhd: {
                    uri: osDiskVhdUri
                }
            }
            imageReference: imageReference
        }
        osProfile: {
            computerName: vmName
            adminUsername: adminUsername
            adminPassword: adminPassword
            linuxConfiguration: {
                disablePasswordAuthentication: false
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: nicId
                }
            ]
        }
    }
}


