@description('The name of the Azure Function app.')
param name string

@description('Location for all resources.')
param location string

@description('Location for all resources.')
param tags object


@description('Only required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string = ''

param isReserved string

param functionSubnetId string
param serverFarmId string


resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: isReserved
  properties: {
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      vnetRouteAllEnabled: true
    }
    httpsOnly: true
    virtualNetworkSubnetId: functionSubnetId
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource keyVaultEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${functionApp.name}-ep'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: functionSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'keyVaultLink'
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: ['vault']
        }
      }
    ]
  }
}


output id string = functionApp.id