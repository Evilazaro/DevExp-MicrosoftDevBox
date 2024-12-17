@description('Workload Name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string = ''

@description('Deploy Identity Resources')
module identityResources '../src/bicep/identity/identityModule.bicep' = {
  name: 'identity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}

@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/devExWorkload.bicep' = {
  name: 'devBox'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
    customRoleName: identityResources.outputs.customRoleName
  }
}
