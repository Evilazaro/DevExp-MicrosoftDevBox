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
    networkConnection:{
      domainJoinType: 'AzureADJoin'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnection:{
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Deploy Connectivity Resources')
module connectivityResources 'connectivity/connectivityWorkload.bicep'= {
  name: 'connectivity'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    projects: contosoProjectsInfo 
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}
