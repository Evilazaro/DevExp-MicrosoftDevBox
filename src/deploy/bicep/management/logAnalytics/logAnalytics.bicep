@description('Log Analytics Workspace Name')
param name string

@description('Tags for the Log Analytics Workspace')
param tags object

@description('Deploy Log Analytics Workspace to Azure')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: resourceGroup().location
  tags: tags
}

@description('Log Analytics Workspace Name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

@description('Log Analytics Diagnostic Settings')
resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${logAnalyticsWorkspace.name}-diagnostic'
  scope: logAnalyticsWorkspace
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
  }
}

@description('Log Analytics Diagnostic Settings ID')
output logAnalyticsDiagnosticSettingsId string = logAnalyticsDiagnosticSettings.id

@description('Log Analytics Diagnostic Settings Name')
output logAnalyticsDiagnosticSettingsName string = logAnalyticsDiagnosticSettings.name
