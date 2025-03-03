targetScope = 'resourceGroup'
@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('application-subnet address prefix')
param trainingSubnetPrefix string = '10.0.0.0/24'

@description('data-subnet address prefix')
param scoringSubnetPrefix string = '10.0.1.0/24'

@description('management-subnetaddress prefix')
param azureBastionSubnetPrefix string = '10.0.2.0/24'

@description('Jumphost virtual machine username')
param Admin-1 string

@secure()
@minLength(8)
@description('Jumphost virtual machine password')
param StudentHogent24-25 string

module vnet 'modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: { location: location }
}

module nsg 'modules/nsg.bicep' = {
  name: 'nsgDeployment'
  params: { location: location }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: { location: location }
}

module vm 'modules/virtualmachine.bicep' = {
  name: 'vmDeployment'
  params: { location: location }
}

module sql 'modules/sql.bicep' = {
  name: 'sqlDeployment'
  params: { location: location }
}

module privateEndpoint 'modules/privateEndpoint.bicep' = {
  name: 'privateEndpointDeployment'
  params: { location: location }
}

