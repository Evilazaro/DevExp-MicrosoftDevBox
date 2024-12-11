@description('Solution/Workload Name')
param workloadName string

@description('Virtual Network Resource Group Name')
param virtualNetworkResourceGroupName string

@description('Dev Center Resource Group Name')
param devCenterResourceGroupName string

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
module deployDevCenter 'devCenter/devCenter.bicep' = {
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
