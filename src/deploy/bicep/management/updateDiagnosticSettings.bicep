param logAnalyticsWorkspaceName string
param devCenterName string
param vnetName string
param devBoxResourceGroupName string
param networkResourceGroupName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
  scope: resourceGroup(devBoxResourceGroupName)
}

resource devCenterDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'devCenterDiagnosticSettings'
  scope: devCenter
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output devCenterDiagnosticSettingsId string = devCenterDiagnosticSettings.id
output devCenterDiagnosticSettingsName string = devCenterDiagnosticSettings.name

resource vNetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vNetDiagnosticSettings'
  scope: virtualNetwork
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output vNetDiagnosticSettingsId string = vNetDiagnosticSettings.id
output vNetDiagnosticSettingsName string = vNetDiagnosticSettings.name
