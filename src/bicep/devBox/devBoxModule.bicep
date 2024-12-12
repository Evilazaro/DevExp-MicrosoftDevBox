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
module deployDevCenter 'devCenter/devCenterResource.bicep' = {
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

@description('Attach Dev Center to Network Connection')
module networkConnectionAttachment 'devCenter/connectivity/networkConnectionAttachmentResource.bicep' = [
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
module environmentTypes 'devCenter/environmentConfiguration/environmentTypeModule.bicep' = {
  name: 'EnvironmentTypes'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}


@description('Configure Catalogs')
module catalogs 'devCenter/environmentConfiguration/catalogModule.bicep' = {
  name: 'Catalogs'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}

@description('Configure Projects')
module projects 'devCenter/management/devCenterProjectModule.bicep' = {
  name: 'Projects'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}
