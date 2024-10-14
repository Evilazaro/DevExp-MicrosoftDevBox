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

@description('Deploy the virtual network')
module virtualNetwork 'virtualNetwork/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: vnetName
    addressPrefix: addressPrefix
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
      sourceAddressPrefix: subnetAddressPrefix
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
      sourceAddressPrefix: subnetAddressPrefix
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
      sourceAddressPrefix: subnetAddressPrefix
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-UDP'
    properties: {
      protocol: 'Udp'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: subnetAddressPrefix
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-TCP'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: subnetAddressPrefix
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 140
      direction: 'Inbound'
    }
  }
]

@description('Deploy the network security group')
module nsg '../security/networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    name: vnetName
    securityRules: securityRules
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('The address prefix of the subnet')
var subnetAddressPrefix = [
  {
    name: 'devBoxSubnet'
    addressPrefix: '10.1.0.0/24'
  }
  {
    name: 'FrontEndSubnet'
    addressPrefix: '10.2.0.0/24'
  }
  {
    name: 'BackEndSubnet'
    addressPrefix: '10.3.0.0/24'
  }
  {
    name: 'dataBaseSubnet'
    addressPrefix: '10.4.0.0/24'
  }
]

@description('Deploy the subnet')
module subnet 'virtualNetwork/subNet.bicep' = {
  name: 'subnet'
  params: {
    virtualNetworkName: virtualNetwork.outputs.name
    subnetAddressPrefix: subnetAddressPrefix
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
    virtualNetwortkName: virtualNetwork.outputs.name
    tags: tags
    name: virtualNetworkConnectionName
  }
  dependsOn: [
    virtualNetwork
    subnet
  ]
}
