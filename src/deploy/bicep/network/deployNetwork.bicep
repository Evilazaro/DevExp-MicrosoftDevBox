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

var logAnalyticsWorkspaceName = '${solutionName}-logAnalytics'
var managementResourceGroupName = 'PetDx-Management-rg'

@description('Deploy the virtual network')
module virtualNetwork 'virtualNetwork/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: vnetName
    addressPrefix: addressPrefix
    tags: tags
  }
}

@description('The name of the virtual network')
output vnetName string = virtualNetwork.outputs.vnetName

@description('Virtual Network Id')
output vnetId string = virtualNetwork.outputs.vnetId

@description('Virtual Network IP Address Space')
output vnetAddressSpace array = virtualNetwork.outputs.vnetAddressSpace

@description('Getting the new Virtual Network Deployed')
resource vnetDeployed 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

@description('Getting the Log Analytics Deployed')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

@description('Creating Virtual Network Diagnostic Settings')
resource virtualNetworkDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vnetName}-DiagnosticSettings'
  scope: vnetDeployed
  properties: {
    logs: [
      {
        category: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
  dependsOn: [
    vnetDeployed
    logAnalyticsWorkspace
  ]
}

@description('Deploy Nsg')
module nsg '../security/networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    name: 'nsg'
    tags: tags
    securityRules:[]
    logAnalyticsWorkSpaceName: logAnalyticsWorkspaceName
  }
}

@description('Network security group id')
output nsgId string = nsg.outputs.nsgId

@description('Network security group name')
output nsgName string = nsg.outputs.nsgName

@description('Deploy the subnet')
module subNet 'virtualNetwork/subNet.bicep' = [
  for subnet in subNets: {
    name: '${subnet.name}-Subnet'
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
    name: '${subnet.name}-con'
    params: {
      name: '${subnet.name}-con'
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
