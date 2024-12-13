@description('Workload name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Subnets')
param projects array

@description('Address Prefixes')
var addressPrefixes = [
  '10.0.0.1/16'
]

@description('Tags')
var tags = {
  workload: workloadName
  landingZone: 'connectivity'
  resourceType: 'virtualNetwork'
}

@description('DDoS Protection Plan')
module ddosProtectionPlan 'DDoSPlan/DDoSPlanResource.bicep'= {
  name: 'ddosProtectionPlan'
  scope: resourceGroup(connectivityResourceGroupName)
  params: {
    name: workloadName
  }
}

@description('Virtual Network Resource')
module virtualNetwork 'virtualNetwork/virtualNetworkResource.bicep'= {
  name: 'virtualNetwork'
  scope: resourceGroup(connectivityResourceGroupName)
  params: {
    name: workloadName
    location: resourceGroup().location
    tags: tags
    addressPrefixes:addressPrefixes 
    ddosProtectionPlanId: ddosProtectionPlan.outputs.ddosProtectionPlanId 
    subnets: projects
  }
}

@description('Network Connection Resource')
module networkConnection 'networkConnection/networkConnectionResource.bicep' = [for netConnection in projects: {
  name: 'netCon-${netConnection.name}'
  scope: resourceGroup(connectivityResourceGroupName)
  params: {
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
    subnetName: netConnection.name
    virtualNetworkResourceGroupName: resourceGroup().name
    domainJoinType: netConnection.networkConnection.domainJoinType
  }
}]
