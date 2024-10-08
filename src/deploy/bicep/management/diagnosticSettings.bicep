@description('Diagnostic Settings Name')
param diagnosticSettingsName string = 'default'

@description('Log Analytics Worskpace Name')
param logAnalyticsWorkspaceName string

@description('Log Analytics Resource Group Name')
param logAnalyticsResourceGroupName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsResourceGroupName)
}

resource diagonisticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
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
    workspaceId: logAnalytics.id
  }
}
