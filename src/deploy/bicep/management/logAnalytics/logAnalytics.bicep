@description('Log Analytics Worspace Name')
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

module diagnosticsSettings 'diagnosticSettings.bicep' = {
  name: 'diagnosticsSettings'
  params: {
    name: '${logAnalyticsWorkspace.name}-diagnosticSettings'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
    logAnalyticsResourceGroupName: resourceGroup().name
  }
}

@description('Diagnostic Settings ID')
output diagnosticSettingsId string = diagnosticsSettings.outputs.diagnosticSettingsId

@description('Diagnostic Settings Name')
output diagnosticSettingsName string = diagnosticsSettings.outputs.diagnosticSettingsName

