@description('Solution Name')
param solutionName string

@description('The name of the virtual network')
var vnetName = format('{0}-vnet', solutionName)

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
}

@description('Virtual Network Name')
output vnetName string = virtualNetwork.outputs.vnetName

@description('Virtual Network Id')
output vnetId string = virtualNetwork.outputs.vnetId

@description('Subnets')
output subnets array = virtualNetwork.outputs.subnets

@description('Deploy the network connection for each subnet')
module netConnection 'networkConnection/networkConnection.bicep' = [
  for subnet in subnetAddressPrefix: {
    name: '${subnet.name}-Connection'
    params: {
      name: '${subnet.name}-Connection'
      vnetName: virtualNetwork.outputs.vnetName
      subnetName: subnet.name
      tags: tags
    }
    dependsOn: [
      virtualNetwork
    ]
  }
]
