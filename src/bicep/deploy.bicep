@description('Workload Name')
param workloadName string

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
  params: {
    projects: projects 
    workloadName: workloadName
  }
}
