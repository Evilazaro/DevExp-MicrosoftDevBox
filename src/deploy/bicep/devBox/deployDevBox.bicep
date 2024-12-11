@description('Workload Name')
param workloadName string

@description('Network Connection Resource Group Name')
param networkConnectionResourceGroupName string

@description('Network Connections')
param networkConnections array

@description('Catalog Item Sync Enable Status')
var catalogItemSyncEnableStatus = 'Enabled'

@description('Microsoft Hosted Network Enable Status')
var microsoftHostedNetworkEnableStatus = 'Enabled'

@description('Install Azure Monitor Agent Enable Status')
var installAzureMonitorAgentEnableStatus = 'Enabled'

@description('Tags')
var tags = {
  division: 'PlatformEngineeringTeam-DevEx'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: workloadName
  landingZone: 'DevBox'
}
@description('Deploy Dev Center resource to Azure')
module deployDevCenter 'devCenter/devCenter.bicep' = {
  name: 'DevCenter'
  scope: resourceGroup()
  params: {
    name: workloadName
    tags: tags
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

@description('Attach Dev Center to Network Connection')
module networkConnectionAttachment 'devCenter/networkConnectionAttachment.bicep' = [
  for networkConnection in networkConnections: {
    name: networkConnection
    params: {
      devCenterName: deployDevCenter.outputs.devCenterName
      name: networkConnection
      networkConnectionResourceGroupName: networkConnectionResourceGroupName
    }
  }
]

@description('Configure Environment Types')
module environmentTypes 'devCenter/environmentConfiguration/deployEnvironmentType.bicep' = {
  name: 'EnvironmentTypes'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}

@description('Output Environment Types')
output environmentTypes array = environmentTypes.outputs.environmentTypeNames

@description('Configure Catalogs')
module catalogs 'devCenter/environmentConfiguration/deployCatalog.bicep' = {
  name: 'Catalogs'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}
