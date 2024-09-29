param solutionName string

var vnetName = format('{0}-vnet', solutionName)
var networkConnectionName = format('{0}-networkConnection', vnetName)

module virtualNetwork './virtualNetwork/deployVnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    vnetName: vnetName
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
    vnetName: virtualNetwork.name
  }
  dependsOn: [
    virtualNetwork
  ]
}

output networkConnectionName string = networkConnection.name
