param logAnalyticsWorkspaceName string

resource deployLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output logAnalyticsWorkspaceId string = deployLogAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = deployLogAnalyticsWorkspace.name
output logAnalyticsWorkspaceLocation string = deployLogAnalyticsWorkspace.location
output logAnalyticsWorkspaceResourceId string = deployLogAnalyticsWorkspace.properties.customerId
output logAnalyticsWorkspacePublicNetworkAccessForIngestion string = deployLogAnalyticsWorkspace.properties.publicNetworkAccessForIngestion
output logAnalyticsWorkspacePublicNetworkAccessForQuery string = deployLogAnalyticsWorkspace.properties.publicNetworkAccessForQuery
output logAnalyticsWorkspaceSkuName string = deployLogAnalyticsWorkspace.properties.sku.name
output logAnalyticsWorkspaceFeaturesLegacy string = deployLogAnalyticsWorkspace.properties.features.legacy
output logAnalyticsWorkspaceFeaturesSearchVersion string = deployLogAnalyticsWorkspace.properties.features.searchVersion

