param location string = resourceGroup().location
param serverName string
param administratorLogin string
param administratorLoginPassword string
param databaseName string

resource server 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: serverName
  location: location
  properties: {
    version: '5.7'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: 5120
    }
    sslEnforcement: 'Enabled'
  }
}

resource database 'Microsoft.DBforMySQL/servers/databases@2017-12-01' = {
  name: '${server.name}/${databaseName}'
  properties: {}
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: 'appServicePlan'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: 'webApp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'DATABASE_HOST'
          value: server.properties.fullyQualifiedDomainName
        }
        {
          name: 'DATABASE_NAME'
          value: databaseName
        }
        {
          name: 'DATABASE_USERNAME'
          value: administratorLogin
        }
        {
          name: 'DATABASE_PASSWORD'
          value: administratorLoginPassword
        }
      ]
      linuxFxVersion: 'PHP|7.4'
    }
  }
}
