targetScope = 'resourceGroup'


@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {
  'IaaS|PaaS': 'PaaS'
}

@description('Jumphost virtual machine username')
param adminUsername string

@secure()
@minLength(8)
@description('Jumphost virtual machine password')
param adminPassword string

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


module vnet 'modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    tags: tags
    virtualNetworkName: 'delw-vne-paas-tst-we-001'
    vnetAddressPrefix : '10.0.0.0/16'
    applicationsubnetPrefix : '10.0.0.0/24'
    dataSubnetPrefix : '10.0.1.0/24'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    networkSecurityGroupId2: nsg2.outputs.networkSecurityGroup
  }
}


  module keyVault 'modules/keyvault.bicep' = {
    name: 'keyVaultDeployment'
    params: {
      keyVaultName: 'delw-kv-paas-tst-we-001'
      location: location
      tags: tags
      tenantId: subscription().tenantId
      keyVaultPrivateDnsZoneName: 'privatel'
      virtualNetworkId: vnet.outputs.id
      subnetId: '${vnet.outputs.id}/subnets/data'
    }
  }


module vm 'modules/virtualmachine.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    tags: tags
    vmName: 'delw-vm-paas-tst-we-001'
    securityType: 'TrustedLaunch'
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: vnet.outputs.id
    publicIPAllocationMethod: 'Dynamic'
    publicIpSku: 'Basic'
    dnsLabelPrefix: 'delw-vm-paas-tst-we-001'
    OSVersion: '2022-datacenter-azure-edition'
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sqlDeployment'
  params: {
    location: location
    tags: tags
    subnetId: virtualNetwork.outputs.subnets[1].id
  }
}


