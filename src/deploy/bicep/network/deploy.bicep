@description('Solution/Workload Name')
param workloadName string

@description('Environment Type')
@allowed([
  'nonprod'
  'prod'
  'dev'
])
param environmentType string

@description('Virtual Network Address Prefixes')
var addressPrefixes = [
  '10.0.0.0/16'
]

@description('Subnets')
var subnets = [
  {
    name: 'eShop'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
  {
    name: 'ContosoTraders'
    properties: {
      addressPrefix: '10.0.1.0/24'
    }
  }
  {
    name: 'DevBox'
    properties: {
      addressPrefix: '10.0.2.0/24'
    }
  }
]

@description('Tags')
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: workloadName
  landingZone: 'DevBox'
}

@description('Deploy Virtual Network Resource')
module deployVirtualNetwork 'virtualNetwork/virtualNetwork.bicep' = {
  name: workloadName
  scope: resourceGroup()
  params: {
    name: workloadName
    location: resourceGroup().location
    tags: tags
    enableDdosProtection: (environmentType == 'prod')
    addressPrefixes: addressPrefixes
    subnets: subnets
  }
}

@description('Virtual Network Resource ID')
output virtualNetworkId string = deployVirtualNetwork.outputs.virtualNetworkId

@description('Virtual Network Resource Name')
output virtualNetworkName string = deployVirtualNetwork.outputs.virtualNetworkName

@description('Virtual Network Resource Location')
output virtualNetworkLocation string = deployVirtualNetwork.outputs.virtualNetworkLocation

@description('Virtual Network Resource Address Prefixes')
output virtualNetworkAddressPrefixes array = deployVirtualNetwork.outputs.virtualNetworkAddressPrefixes

@description('Virtual Network Resource Subnets')
output virtualNetworkSubnets array = deployVirtualNetwork.outputs.virtualNetworkSubnets

@description('Tags')
output virtualNetworkTags object = deployVirtualNetwork.outputs.virtualNetworkTags
