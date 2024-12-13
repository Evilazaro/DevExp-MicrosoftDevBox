@description('Workload Name')
param workloadName string

@description('DevBox Workload Resource Group Name')
param devBoxResourceGroupName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Projects')
var contosoProjectsInfo = [
  {
    name: 'eShop'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Contoso Dev Center Catalog')
var contosoDevCenterCatalog = {
  name: 'Contoso-DevCenter'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/customizations/tasks'
}

@description('Deploy Connectivity Resources')
module connectivityResources 'connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    contosoProjectsInfo: contosoProjectsInfo
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}

@description('Deploy DevEx Resources')
module devExResources 'DevEx/devExWorkload.bicep' = {
  name: 'DevBox'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    workloadName: workloadName
    contosoProjectsInfo: contosoProjectsInfo
    networkConnections: connectivityResources.outputs.networkConnections
    connectivityResourceGroupName: connectivityResourceGroupName
    devCenterCatalog: contosoDevCenterCatalog
  }
}
