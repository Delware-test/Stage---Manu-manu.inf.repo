@description('name for the web app name')
param webAppName string

@description('The SKU of App Service Plan.')
param sku string 

@description('The runtime stack of web app')
param linuxFxVersion string

@description('Location for all resources.')
param location string

@description('Tags to add to the resources')
param tags object

@description('name of App Service Plan.')
param appServicePlanName string

param keyVaultName string

param secretName string


@description('name for the web app name')
var webSiteName = toLower('wapp-${webAppName}')



param AppInsightsID string


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
  identity: {
    type: 'SystemAssigned'  // This enables the system-assigned managed identity
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(AppInsightsID, '2015-05-01').InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference(AppInsightsID, '2015-05-01').ConnectionString
        }
        {
          name: 'MY_SECRET' // This is the environment variable name
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/${secretName}/)'
        }
      ]
    }
    
  }
  
}

output id string = appService.identity.principalId
output apsid string = appServicePlan.id