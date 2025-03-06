@description('Create a Network Security Group with default rules')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the Network Security Group')
param nsgName1 string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName1
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'NSG_voor_app_subnet'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.0.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}




output networkSecurityGroup string = nsg.id
