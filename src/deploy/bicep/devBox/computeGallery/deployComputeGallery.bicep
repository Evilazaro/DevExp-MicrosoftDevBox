param computeGalleryName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

resource deployComputeGallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: computeGalleryName
  location: resourceGroup().location
  properties: {
    description: 'Compute gallery for Microsoft Dev Box Custom Images'
  }
}

output computeGalleryId string = deployComputeGallery.id
output computeGalleryName string = deployComputeGallery.name

resource vNetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vNetDiagnosticSettings'
  scope: deployComputeGallery
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

output vNetDiagnosticSettingsId string = vNetDiagnosticSettings.id
output vNetDiagnosticSettingsName string = vNetDiagnosticSettings.name
