param solutionName string

var vnetName = format('{0}-vnet', solutionName)
var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)
var managementResourceGroupName = format('{0}-Management-rg', solutionName)
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Networking'
}

module virtualNetwork './virtualNetwork/deployVnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    vnetName: vnetName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    managementResourceGroupName: managementResourceGroupName
    tags: tags
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
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

output networkConnectionName string = networkConnection.name
