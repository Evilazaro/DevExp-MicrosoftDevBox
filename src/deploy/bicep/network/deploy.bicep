param vnetName string
param subnetName string
param networkConnectionName string

module deployVnet 'deployVnet.bicep' = {
  name: 'deployVnet'
  params: {
    vnetName: vnetName
    subnetName: subnetName
  }
}

output vnetId string = deployVnet.outputs.vnetId
output subnetId string = deployVnet.outputs.subnetId
output subnetName string = deployVnet.outputs.subnetName
output addressPrefix string = deployVnet.outputs.addressPrefix
output vnetName string = deployVnet.name

module deployNetworkConnection 'createNetWorkConnection.bicep' = {
  name: 'deployNetworkConnection'
  params: {
    name: networkConnectionName
    subnetId: deployVnet.outputs.subnetId
    location: resourceGroup().location
  }
  dependsOn: [
    deployVnet
  ]
}

output networkConnectionName string = deployNetworkConnection.name
