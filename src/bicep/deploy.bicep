@description('Solution/Workload Name')
param workloadName string

@description('Virtual Network Resource Group Name')
param virtualNetworkResourceGroupName string

@description('Dev Center Resource Group Name')
param devCenterResourceGroupName string

@description('Environment Type')
@allowed([
  'nonprod'
  'prod'
  'dev'
])
param environmentType string

@description('Deploy Network Connectivity Resources')
module deployNetworkConnectivity 'network/connectivityModule.bicep' = {
  name: 'Connectivity'
  params: {
    environmentType: environmentType
    virtualNetworkResourceGroupName: virtualNetworkResourceGroupName 
    workloadName: workloadName
  }
}

@description('Network Connections names')
var networkConnections = deployNetworkConnectivity.outputs.networkConnectionNames

@description('Deploy Dev Box Resources')
module deployDevBox 'devBox/devBoxModule.bicep' = {
  name: 'DevBox'
  scope: resourceGroup(devCenterResourceGroupName)
  params: {
    workloadName: workloadName
    networkConnectionResourceGroupName:virtualNetworkResourceGroupName
    networkConnections: networkConnections
  }
}

