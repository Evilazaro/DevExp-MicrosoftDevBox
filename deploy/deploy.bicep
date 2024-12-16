@description('Workload Name')
param workloadName string

@description('DevBox Workload Resource Group Name')
param devBoxResourceGroupName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}

@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/devExWorkload.bicep' = {
  name: 'devBox'
  scope: resourceGroup(devBoxResourceGroupName)
  params: {
    workloadName: workloadName
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
  }
}
