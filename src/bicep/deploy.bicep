@description('Workload Name')
param workloadName string

@description('DevBox Workload Resource Group Name')
param devBoxResourceGroupName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Connectivity Info')
var contosoConnectivityInfo = [
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

@description('Deploy Connectivity Resources')
module connectivityResources 'connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    contosoProjectsInfo: contosoConnectivityInfo
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
    networkConnections: connectivityResources.outputs.networkConnections
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}
