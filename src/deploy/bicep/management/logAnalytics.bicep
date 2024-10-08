@description('Log Analytics Worspace Name')
param logAnalyticsWorkspaceName string

@description('Tags for the Log Analytics Workspace')
param tags object

@description('Deploy Log Analytics Workspace to Azure')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  tags: tags
}

@description('Log Analytics Workspace Name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
