param devCenterName string
param logAnalyticsWorkspaceName string

resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup('managementResourceGroupName')
}

@description('Create DevCenter Diagnostic Settings')
resource devCenterDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'devCenterDiagnosticSettings'
  scope: devCenter
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

output devCenterDiagnosticSettingsId string = devCenterDiagnosticSettings.id
output devCenterDiagnosticSettingsName string = devCenterDiagnosticSettings.name	
output devCenterDiagnosticSettingsWorkspaceId string = logAnalyticsWorkspace.id
