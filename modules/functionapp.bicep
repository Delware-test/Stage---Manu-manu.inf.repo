@description('The name of the Azure Function app.')
param name string

@description('Location for all resources.')
param location string

@description('Location for all resources.')
param tags object


@description('Only required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string

@description('The kind of the app service plan.')
param isReserved string

@description('The subnet id of the function app.')
param functionSubnetId string

@description('The server farm id of the function app.')
param serverFarmId string

@description('The app insights id of the function app.')
param AppInsightsID string


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
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(AppInsightsID, '2015-05-01').InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference(AppInsightsID, '2015-05-01').ConnectionString
        }
      ]
    }
    httpsOnly: true
    virtualNetworkSubnetId: functionSubnetId
  }
  identity: {
    type: 'SystemAssigned'
  }
}



output id string = functionApp.identity.principalId