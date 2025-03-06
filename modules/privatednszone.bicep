@description('De naam van de Key Vault dns zone')
param privateDnsZoneName string

@description('Tags om toe te passen op de Key Vault')
param tags object

@description('id van virtual network')
param virtualNetworkId string

@description('De naam van de Key Vault dns zone link')
param privateDnsZoneLinkName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
  properties: {}
}


resource PrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: privateDnsZoneLinkName
  location: 'global'
  tags: tags
  parent: privateDnsZone
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

