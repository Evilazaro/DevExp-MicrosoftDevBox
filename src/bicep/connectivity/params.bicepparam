using 'connectivityWorkload.bicep'

@description('Workload name')
param workloadName = 'myWorkloadName'

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName = 'myConnectivityResourceGroupName'

@description('Connectivity Info')
param contosoConnectivityInfo = [
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

@description('Address Prefixes')
param addressPrefixes = [
  '10.0.0.0/16'
]

@description('Tags')
param tags = {
  workload: workloadName
  landingZone: 'connectivity'
  resourceType: 'virtualNetwork'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}
