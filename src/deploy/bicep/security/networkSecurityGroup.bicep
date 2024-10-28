@description('The name of the network security group')
param name string

@description('The security rules of the network security group')
param securityRules array

@description('The tags of the network security group')
param tags object

@description('The log analytics workspace')
param logAnalyticsWorkSpaceName string

@description('Deploy a network security group to Azure')
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${name}-nsg'
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

@description('Network security group id')
output nsgId string = nsg.id

@description('Network security group name')
output nsgName string = nsg.name

@description('Get an existent log analytics workspace')
resource logAnalyticsWorkSpace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkSpaceName
}

@description('Deploy the diagnostic settings')
resource nsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: nsg.name
  scope: nsg
  properties: {
    logs: [
      {
        category: 'AllLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkSpace.id
  }
}

@description('Diagnostic Settings ID')
output nsgDiagnosticSettingsId string = nsgDiagnosticSettings.id

@description('Diagnostic Settings Name')
output nsgDiagnosticSettingsName string = nsgDiagnosticSettings.name
