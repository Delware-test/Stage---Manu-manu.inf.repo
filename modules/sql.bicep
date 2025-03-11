@description('The name of the SQL logical server.')
param serverName string

@description('The name of the SQL Database.')
param sqlDBName string

@description('Location for all resources.')
param location string

@description('The administrator username of the SQL logical server.')
param adminUsername string

@description('The administrator password of the SQL logical server.')
@secure()
param adminPassword string

@description('tags')
param tags object

@description('The name of the SQL SKU.')
param namesqldb string

@description('The tier of the SQL SKU.')
@secure()
param tier string

@description('The subnet id of the SQL logical server.')
param subnetId string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: namesqldb
    tier: tier
  }
}


resource SqlServerEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${sqlServer.name}-ep'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'sqlserverLink'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: ['sqlserver']
        }
      }
    ]
  }
}