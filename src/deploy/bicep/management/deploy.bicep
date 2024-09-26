param logAnalyticsWorkspaceName string

module logAnalytics 'deployLogAnalytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

module dashboards 'deployDashboards.bicep' = {
  name: 'dashboards'
  dependsOn: [
    logAnalytics
  ]
}

output dashboardsId string = dashboards.outputs.AzureInventoryId
output dashboardsName string = dashboards.outputs.AzureInventoryName
output dashboardsType string = dashboards.outputs.AzureInventoryType
