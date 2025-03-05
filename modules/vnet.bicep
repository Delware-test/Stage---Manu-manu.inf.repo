@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('application-subnet address prefix')
param applicationsubnetPrefix string = '10.0.0.0/24'

@description('Scoring subnet address prefix')
param dataSubnetPrefix string = '10.0.1.0/24'

@description('Network security group id')
param networkSecurityGroupId string

@description('Network security group id')
param networkSecurityGroupId2 string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      { 
        name: 'application'
        properties: {
          addressPrefix: applicationsubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
      { 
        name: 'data'
        properties: {
          addressPrefix: dataSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId2
          }
        }
      }
    ]
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
