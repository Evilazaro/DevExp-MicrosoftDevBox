param solutionName string

var vnetName = format('{0}-vnet', solutionName)
var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)
var managementResourceGroupName = format('{0}-Management-rg', solutionName)

module virtualNetwork './virtualNetwork/deployVnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    vnetName: vnetName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    managementResourceGroupName: managementResourceGroupName
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
    vnetName: virtualNetwork.outputs.vnetName
  }
  dependsOn: [
    virtualNetwork
  ]
}

output networkConnectionName string = networkConnection.name
