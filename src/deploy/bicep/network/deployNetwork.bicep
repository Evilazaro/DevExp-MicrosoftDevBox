@description('Solution Name')
param solutionName string

@description('The name of the virtual network')
var vnetName = format('{0}-vnet', solutionName)

@description('The name of the log analytics workspace')
var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)

@description('The name of the management resource group')
var managementResourceGroupName = format('{0}-Management-rg', solutionName)

@description('The tags of the virtual network')
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Network'
}

@description('Log Analytics deployed to the management resource group')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

@description('The address prefix of the virtual network')
var addressPrefix = [
  '10.0.0.0/16'
]

@description('The address prefix of the subnet')
var subnetAddressPrefix = [
  {
    name: 'eShop'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'contosoTraders'
    addressPrefix: '10.0.1.0/24'
  }
]

@description('Deploy the virtual network')
module virtualNetwork 'virtualNetwork/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: vnetName
    addressPrefix: addressPrefix
    subnets: subnetAddressPrefix
    tags: tags
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

@description('Virtual Network Name')
output vnetName string = virtualNetwork.outputs.vnetName

@description('Virtual Network Id')
output vnetId string = virtualNetwork.outputs.vnetId

@description('Deploy the network connection for each subnet')
module netConnection 'networkConnection/networkConnection.bicep' = [
  for subnet in subnetAddressPrefix: {
    name: '${subnet.name}-Connection'
    params: {
      name: subnet.name
      vnetName: virtualNetwork.name
      subnetName: subnet.name
      tags: tags
    }
    dependsOn: [
      virtualNetwork
    ]
  }
]
