@description('The name of the solution')
param solutionName string

var tags = {
  displayName: 'Log Analytics Workspace'
}

@description('Deploy the log analytics workspace')
module logAnalytics 'logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: '${solutionName}-logAnalytics'
    tags: tags
  }
}

@description('Log Analytics Workspace Name')
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
