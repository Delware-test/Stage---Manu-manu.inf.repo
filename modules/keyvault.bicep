@description('De naam van de Key Vault')
param keyVaultName string

@description('Azure regio waarin de Key Vault wordt aangemaakt')
param location string

@description('Tags om toe te passen op de Key Vault')
param tags object

@description('Tenant id voor de Key Vault')
param tenantId string

@description('Required. Resource ID of the subnet for private endpoints.')
param subnetId string

@description('id van app service')
param appServiceId string

@description('id van app service')
param appFunctionId string


@description('Naam van het geheim in Key Vault')
param secretName string

@secure()
@description('Waarde van het geheim')
param secretValue string

// Definieer standaard access policies (aanpasbaar of parametriseerbaar indien gewenst)
param accessPolicies array = [
  {
    tenantId: tenantId
    objectId: appServiceId
    permissions: {
      certificates: []
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
  {
    tenantId: tenantId
    objectId: appFunctionId
    permissions: {
      certificates: []
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
]

// Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2016-10-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableSoftDelete: true
    createMode: 'default'
    tenantId: subscription().tenantId
    accessPolicies: accessPolicies
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

// 🔹 Add Secret to Key Vault
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: secretName  // Secret name inside Key Vault
  parent: keyVault
  properties: {
    value: secretValue  // Secret Value (Do not store sensitive values in plain text)
  }
}

resource keyVaultEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${keyVault.name}-ep'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'keyVaultLink'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}
