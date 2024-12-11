@description('Solution/Workload Name')
param workloadName string

@description('Virtual Network Resource Group Name')
param virtualNetworkResourceGroupName string

@description('Dev Center Resource Group Name')
param devCenterResourceGroupName string

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
module deployVirtualNetwork 'network/virtualNetwork/virtualNetwork.bicep' = {
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

@description('Deploy Network Connection Resource')
module deployNetWorkConnection 'network/networkConnection/networkConnection.bicep' = [
  for subnet in subnets: {
    name: '${subnet.name}-connection'
    scope: resourceGroup()
    params: {
      virtualNetworkName: deployVirtualNetwork.outputs.virtualNetworkName
      subnetName: subnet.name
      virtualNetworkResourceGroupName: resourceGroup().name
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Catalog Item Sync Enable Status')
var catalogItemSyncEnableStatus = 'Enabled'

@description('Microsoft Hosted Network Enable Status')
var microsoftHostedNetworkEnableStatus = 'Enabled'

@description('Install Azure Monitor Agent Enable Status')
var installAzureMonitorAgentEnableStatus = 'Enabled'

var devCenterTags = {
  division: 'PlatformEngineeringTeam-DevEx'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: workloadName
  landingZone: 'Dev Center'
}

@description('Deploy Dev Center resource to Azure')
module deployDevCenter 'devBox/devCenter/devCenter.bicep' = {
  name: 'DevCenter'
  scope: resourceGroup(devCenterResourceGroupName)
  params: {
    name: workloadName
    tags: devCenterTags
    location: resourceGroup().location
    catalogItemSyncEnableStatus: catalogItemSyncEnableStatus
    microsoftHostedNetworkEnableStatus: microsoftHostedNetworkEnableStatus
    installAzureMonitorAgentEnableStatus: installAzureMonitorAgentEnableStatus
  }
  dependsOn: [
    deployVirtualNetwork
  ]
}

@description('Output Dev Center resource id')
output devCenterId string = deployDevCenter.outputs.devCenterId

@description('Output Dev Center name')
output devCenterName string = deployDevCenter.outputs.devCenterName

@description('Output Dev Center Catalog Item Sync Enable Status')
output catalogItemSyncEnableStatus string = deployDevCenter.outputs.devCenterCatalogItemSyncEnableStatus

@description('Output Dev Center Microsoft Hosted Network Enable Status')
output microsoftHostedNetworkEnableStatus string = deployDevCenter.outputs.devCenterMicrosoftHostedNetworkEnableStatus

@description('Output Dev Center Install Azure Monitor Agent Enable Status')
output installAzureMonitorAgentEnableStatus string = deployDevCenter.outputs.devCenterInstallAzureMonitorAgentEnableStatus

@description('Output Dev Center location')
output devCenterLocation string = deployDevCenter.outputs.devCenterLocation
