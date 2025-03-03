param location string = 'westeurope'

module vnet './vnet.bicep' = {
  name: 'vnetDeployment'
  params: { location: location }
}

module nsg './nsg.bicep' = {
  name: 'nsgDeployment'
  params: { location: location }
}

module keyVault './keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: { location: location }
}

module vm './virtualmachine.bicep' = {
  name: 'vmDeployment'
  params: { location: location }
}

module sql './sql.bicep' = {
  name: 'sqlDeployment'
  params: { location: location }
}

module privateEndpoint './privateEndpoint.bicep' = {
  name: 'privateEndpointDeployment'
  params: { location: location }
}
