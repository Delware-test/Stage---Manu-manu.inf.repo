@description('Create a Network Security Group with default rules')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the Network Security Group')
param nsgName2 string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName2
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'DenySpokeInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.0.0.0/16'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAPPServerToKeyVault'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.0.0.0/24'
          destinationAddressPrefix: '10.0.1.5'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowvmTodatasub'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.0.2.5'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  }
}

output networkSecurityGroup string = nsg.id
