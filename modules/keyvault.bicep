@description('name for the web app name')
param webAppName string

@description('The SKU of App Service Plan.')
param sku string 

@description('The runtime stack of web app')
param linuxFxVersion string

@description('Location for all resources.')
param location string

param tags object

@description('name of App Service Plan.')
param appServicePlanName string

@description('name for the web app name')
param subnetId string

@description('name for the web app name')
var webSiteName = toLower('wapp-${webAppName}')



resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}


resource appServiceEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${appService.name}-ep'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'appServiceLink'
        properties: {
          privateLinkServiceId: appService.id
          groupIds: ['appService']
        }
      }
    ]
  }
}




output id string = appService.id