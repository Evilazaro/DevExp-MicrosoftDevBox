@description('Solution/Workload Name')
param workloadName string

@description('Virtual Network Resource Group Name')
param virtualNetworkResourceGroupName string

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
  division: 'PlatformEngineeringTeam-DevEx'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: workloadName
  landingZone: 'Networking'
}

@description('Deploy Virtual Network Resource')
module deployVirtualNetwork 'virtualNetwork/virtualNetworkResource.bicep' = {
  name: 'VirtualNetwork'
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    name: workloadName
    location: resourceGroup().location
    tags: tags
    enableDdosProtection: (environmentType == 'prod')
    addressPrefixes: addressPrefixes
    subnets: subnets
  }
}

@description('Deploy Network Connection Resource')
module deployNetWorkConnection 'networkConnection/networkConnectionResource.bicep' = [
  for subnet in subnets: {
    name: '${subnet.name}-connection'
    scope: resourceGroup(virtualNetworkResourceGroupName)
    params: {
      virtualNetworkName: deployVirtualNetwork.outputs.virtualNetworkName
      subnetName: subnet.name
      virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Network Connection Resource Names')
output networkConnectionNames array = [for (subnet, i) in subnets: deployNetWorkConnection[i].outputs.networkConnectionName]
