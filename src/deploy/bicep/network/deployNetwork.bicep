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

@description('Deploy the virtual network')
module virtualNetwork 'virtualNetwork/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    virtualNetworkName: vnetName 
    tags: tags
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}


@description('The security rules of the network security group')
var securityRules = [
  {
    name: 'Allow-SSH'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-HTTP'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-HTTPS'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
]

@description('Deploy the network security group')
module nsg '../security/networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    nsgName: vnetName
    securityRules: securityRules
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('Deploy the subnet')
module subnet './virtualNetwork/subNet.bicep' = {
  name: 'subnet'
  params: {
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
    nsgId: nsg.outputs.nsgId
  }
  dependsOn: [
    virtualNetwork
    nsg
  ]
}

@description('Network Connection Name')
var virtualNetworkConnectionName = format('{0}-networkConnection', solutionName)

@description('Deploy the network connection')
module networkConnection './networkConnection/networkConnection.bicep' = {
  name: 'networkConnection'
  params: {
    virtualNetwortkName: virtualNetwork.outputs.virtualNetworkName
    tags: tags
    virtualNetworkConnectionName: virtualNetworkConnectionName
  }
  dependsOn: [
    virtualNetwork
    subnet
  ]
}
