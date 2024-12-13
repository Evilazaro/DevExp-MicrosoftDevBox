@description('Workload Name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Projects')
var projects = [
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
  scope: resourceGroup()
  params: {
    projects: projects 
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}
