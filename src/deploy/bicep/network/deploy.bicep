param vnetName string
param subnetName string
param networkConnectionName string

module virtualNetwork './virtualNetwork/deployVnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    vnetName: vnetName
    subnetName: subnetName
  }
}

output vnetId string = virtualNetwork.outputs.vnetId
output subnetId string = virtualNetwork.outputs.subnetId
output subnetName string = virtualNetwork.outputs.subnetName
output addressPrefix string = virtualNetwork.outputs.addressPrefix
output vnetName string = virtualNetwork.name

module networkConnection './networkConnection/createNetWorkConnection.bicep' = {
  name: 'networkConnection'
  params: {
    name: networkConnectionName
    subnetId: virtualNetwork.outputs.subnetId
    location: resourceGroup().location
  }
  dependsOn: [
    virtualNetwork
  ]
}

output networkConnectionName string = networkConnection.name
