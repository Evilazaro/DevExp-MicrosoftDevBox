@description('Workload Name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Network Connections')
param networkConnections array

@description('Dev Center Catalog')
param devCenterCatalog object

@description('Tags')
var tags = {
  workload: workloadName
  landingZone: 'DevEx'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Dev Center Resource')
module devCenter 'DevCenter/devCenter.bicep' = {
  name: 'devCenter'
  scope: resourceGroup()
  params: {
    name: workloadName
    location: resourceGroup().location
    catalogItemSyncEnableStatus: 'Enabled'
    microsoftHostedNetworkEnableStatus: 'Enabled'
    installAzureMonitorAgentEnableStatus: 'Enabled'
    tags: tags
  }
}

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachment.bicep' = [
  for (networkConnection, i) in networkConnections: {
    name: '${contosoProjectsInfo[i].name}-${networkConnection.name}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      networkConnectionResourceGroupName: connectivityResourceGroupName
      name: networkConnection.name
    }
  }
]

@description('Contoso Dev Center Catalog')
module contosoDevCenterCatalog 'DevCenter/EnvironmentConfiguration/catalogs.bicep' = {
  name: 'DevCenterCatalog'
  scope: resourceGroup()
  params: {
    name: devCenterCatalog.name
    tags: tags
    branch: devCenterCatalog.branch
    devCenterName: devCenter.outputs.devCenterName
    path: devCenterCatalog.path
    syncType: devCenterCatalog.syncType
    type: devCenterCatalog.type
    uri: devCenterCatalog.uri
  }
}

// @description('Network Connection Attachments')
// output networkConnectionAttachments array = [
//   for (networkConnectionAttachment, i) in networkConnections: {
//     name: networkConnectionAttachment[i].name
//     id: networkConnectionAttachment[i].id
//     networkConnectionId: networkConnectionAttachment[i].outputs.networkConnectionId
//   }
// ]
