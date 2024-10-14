@description('Solution Name')
param solutionName string

@description('The name of the virtual network')
var vnetName = format('{0}-vnet', solutionName)

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
var subNets = [
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
    tags: tags
  }
}

@description('Deploy Nsg')
module nsg '../security/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    name: 'nsg'
    tags: tags
    securityRules:[]
  }
}

@description('Deploy the subnet')
module subNet 'virtualNetwork/subNet.bicep' = [
  for subnet in subNets: {
    name: '${subnet.name}-Deployment'
    params: {
      name: subnet.name
      vnetName: virtualNetwork.outputs.vnetName
      subnetAddressPrefix: subnet.addressPrefix
      nsgId: nsg.outputs.nsgId
    }
    dependsOn: [
      virtualNetwork
      nsg
    ]
  }
]

@description('Deploy the network connection for each subnet')
module netConnection 'networkConnection/networkConnection.bicep' = [
  for subnet in subNets: {
    name: '${subnet.name}-Connection'
    params: {
      name: '${subnet.name}-Connection'
      vnetName: virtualNetwork.outputs.vnetName
      subnetName: subnet.name
      tags: tags
    }
    dependsOn: [
      virtualNetwork
      subNet
    ]
  }
]
