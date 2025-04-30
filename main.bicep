targetScope = 'resourceGroup'


@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {
  'IaaS|PaaS': 'PaaS'
}


module nsg 'modules/nsg.bicep' = { 
  name: 'nsgdeploymentapplicationsub'
  params: {
    location: location
    tags: tags 
    nsgName1: 'delw-nsg-paas-tst-application-we-001'
  }
}

module nsg2 'modules/nsg2.bicep' = { 
  name: 'nsgdeploymentdatasub'
  params: {
    location: location
    tags: tags 
    nsgName2: 'delw-nsg-paas-tst-data-we-002'
  }
}

module nsg3 'modules/nsg2.bicep' = { 
  name: 'nsgdeploymentmanagementsub'
  params: {
    location: location
    tags: tags 
    nsgName2: 'delw-nsg-paas-tst-data-we-003'
  }
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    tags: tags
    virtualNetworkName: 'delw-vne-paas-tst-we-004'
    vnetAddressPrefix : '10.0.0.0/16'
    applicationsubnetPrefix : '10.0.0.0/24'
    dataSubnetPrefix : '10.0.1.0/24'
    managementSubnetPrefix : '10.0.2.0/24'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    networkSecurityGroupId2: nsg2.outputs.networkSecurityGroup
    networkSecurityGroupId3: nsg3.outputs.networkSecurityGroup
  }
}

module paasprivatednszone 'modules/privatednszone.bicep' = {
  name: 'paasprivatednszoneDeployment'
  params: {
    tags: tags
    privateDnsZoneName: 'paasdnszone.local'
    virtualNetworkId: vnet.outputs.id
    privateDnsZoneLinkName: 'PaaS-link'
  }
}



module applicationinsights 'modules/applicationinsights.bicep' = {
  name: 'applicationinsightsDeployment'
  params: {
    location: location
    tags: tags
    name: 'delw-ai-paas-tst-we-004'
    logAnalyticsWorkspaceName: 'delw-law-paas-tst-we-004'
  }
}

module aps 'modules/appserviceplan.bicep' = {
  name: 'appserviceDeployment'
  params: {
    location: location
    tags: tags
    webAppName : 'delw-as-paas-tst-we-004'
    appServicePlanName: 'delw-aps-paas-tst-we-004'
    sku: 'B1'
    linuxFxVersion: 'PYTHON|3.12'
    AppInsightsID: applicationinsights.outputs.applicationInsightsId
    keyVaultName:  'delw-kv-paas-tst-we-004'
    secretName: 'mysecret'
  }
}

module funcionapp 'modules/functionapp.bicep' = {
  name: 'functionappDeployment'
  params: {
    name:'delw-func-paas-tst-we-004'
    location:location
    tags: tags
    linuxFxVersion: 'Python|3.11'
    serverFarmId: aps.outputs.apsid
    isReserved: 'functionapp,linux'
    functionSubnetId: '${vnet.outputs.id}/subnets/application'
    AppInsightsID: applicationinsights.outputs.applicationInsightsId
    keyVaultName:  'delw-kv-paas-tst-we-004'
    secretName: 'mysecret'
  }
}



