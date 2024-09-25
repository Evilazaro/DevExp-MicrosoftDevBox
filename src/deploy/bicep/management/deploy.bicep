param logAnalyticsWorkspaceName string

module logAnalytics 'deployLogAnalytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    logAnalyticsWorkspaceName: 'logAnalyticsWorkspaceName'
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

module azureDashboard 'dashboard.bicep' = {
  name: 'Azure-Inventory'
  dependsOn: [
    logAnalytics
  ]
}
