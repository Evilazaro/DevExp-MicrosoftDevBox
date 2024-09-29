param vnetName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

var addressPrefixes = [
  '10.0.0.0/16'
]
var subnetPrefix = '10.0.0.0/24'

@description('Deploy Virtual Network and Subnet')
resource deployVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: format('{0}-subnet', vnetName)
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

output vnetId string = deployVirtualNetwork.id
output subnetId string = deployVirtualNetwork.properties.subnets[0].id
output subnetName string = deployVirtualNetwork.properties.subnets[0].name
output addressPrefix string = deployVirtualNetwork.properties.subnets[0].properties.addressPrefix
output vnetName string = deployVirtualNetwork.name

resource vNetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vNetDiagnosticSettings'
  scope: deployVirtualNetwork
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output vNetDiagnosticSettingsId string = vNetDiagnosticSettings.id
output vNetDiagnosticSettingsName string = vNetDiagnosticSettings.name


