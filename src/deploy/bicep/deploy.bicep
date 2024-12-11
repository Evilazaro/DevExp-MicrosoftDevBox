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

@description('Deploy Network Connectivity Resources')
module deployNetworkConnectivity 'network/virtualNetwork/deployVnet.bicep' = {
  name: 'VirtualNetwork'
  params: {
    environmentType: environmentType
    virtualNetworkResourceGroupName: virtualNetworkResourceGroupName 
    workloadName: workloadName
  }
}

@description('Virtual Network Resource ID')
output virtualNetworkId string = deployNetworkConnectivity.outputs.virtualNetworkId

@description('Virtual Network Resource Name')
output virtualNetworkName string = deployNetworkConnectivity.outputs.virtualNetworkName

@description('Virtual Network Resource Location')
output virtualNetworkLocation string = deployNetworkConnectivity.outputs.virtualNetworkLocation

@description('Virtual Network Resource Address Prefixes')
output virtualNetworkAddressPrefixes array = deployNetworkConnectivity.outputs.virtualNetworkAddressPrefixes

@description('Virtual Network Resource Subnets')
output virtualNetworkSubnets array = deployNetworkConnectivity.outputs.virtualNetworkSubnets

@description('Tags')
output virtualNetworkTags object = deployNetworkConnectivity.outputs.virtualNetworkTags


@description('Deploy Dev Box Resources')
module deployDevBox 'devBox/deployDevBox.bicep' = {
  name: 'DevBox'
  params: {
    workloadName: workloadName
    devCenterResourceGroupName: devCenterResourceGroupName
    virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
  }
}

@description('Output Dev Center resource id')
output devCenterId string = deployDevBox.outputs.devCenterId

@description('Output Dev Center name')
output devCenterName string = deployDevBox.outputs.devCenterName

@description('Output Dev Center Catalog Item Sync Enable Status')
output catalogItemSyncEnableStatus string = deployDevBox.outputs.catalogItemSyncEnableStatus

@description('Output Dev Center Microsoft Hosted Network Enable Status')
output microsoftHostedNetworkEnableStatus string = deployDevBox.outputs.microsoftHostedNetworkEnableStatus

@description('Output Dev Center Install Azure Monitor Agent Enable Status')
output installAzureMonitorAgentEnableStatus string = deployDevBox.outputs.installAzureMonitorAgentEnableStatus

@description('Output Dev Center location')
output devCenterLocation string = deployDevBox.outputs.devCenterLocation

