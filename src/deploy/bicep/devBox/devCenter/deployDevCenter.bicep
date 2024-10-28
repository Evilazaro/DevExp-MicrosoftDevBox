@description('DevCenter Name')
param name string

@description('Identity Name')
param identityName string

@description('Compute Gallery Name')
param computeGalleryName string

@description('Projects')
param projects array

@description('Network Resource Group Name')
param networkResourceGroupName string

param catalogInfo object

@description('Tags')
param tags object

@description('Log Analytics Workspace Name')
param logAnalyticsWorkspaceName string

@description('Managed Identity')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

@description('Deploying DevCenter')
resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    displayName: name
  }
  tags: tags
  dependsOn: [
    managedIdentity
  ]
}

@description('Dev Center Name')
output devCenterName string = deployDevCenter.name

@description('Dev Center Id')
output devCenterId string = deployDevCenter.id

@description('Existing Log Analytics Workspace')
resource devCenterLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}

@description('Dev Center Log Analytics Diagnostic Settings')
resource devCenterLogAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: devCenterLogAnalyticsWorkspace.name
  scope: devCenterLogAnalyticsWorkspace
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
    workspaceId: devCenterLogAnalyticsWorkspace.id
  }
}

@description('Dev Center Log Analytics Diagnostic Settings Id')
output devCenterLogAnalyticsDiagnosticSettingsId string = devCenterLogAnalyticsDiagnosticSettings.id

@description('Dev Center Log Analytics Diagnostic Settings Name')
output devCenterLogAnalyticsDiagnosticSettingsName string = devCenterLogAnalyticsDiagnosticSettings.name

@description('Dev Center Environments')
module devCenterEnvironments 'configureDevCenterEnvironments.bicep' = {
  name: 'devCenterEnvironments'
  params: {
    devCenterName: name
  }
  dependsOn: [
    deployDevCenter
  ]
}

@description('Dev Center Catalogs')
module configureDevCenterCatalogs 'configureDevCenterCatalogs.bicep' = {
  name: '${deployDevCenter.name}-Catalog'
  params: {
    devCenterName: deployDevCenter.name
    catalogInfo: catalogInfo
  }
}

@description('Dev Center Network Connection')
module configureDevCenterNetworkConnection 'configureDevCenterNetworkConnection.bicep' = [
  for project in projects: {
    name: '${project.networkConnectionName}'
    params: {
      devCenterName: name
      networkConnectionName: project.networkConnectionName
      networkResourceGroupName: networkResourceGroupName
    }
    dependsOn: [
      deployDevCenter
    ]
  }
]

var connections = [
  for i in range(0, length(projects)): {
    name: projects[i].name
  }
]
output connectionNames array = connections

@description('Dev Center Compute Gallery')
module configureDevCenterComputeGallery 'configureDevCenterComputeGallery.bicep' = {
  name: 'devCenterComputeGallery'
  params: {
    devCenterName: name
    computeGalleryName: computeGalleryName
  }
  dependsOn: [
    deployDevCenter
  ]
}

@description('Dev Box Definitions')
module configureDevBoxDefinitions 'configureDevBoxDefinitions.bicep' = {
  name: 'devBoxDefinitions'
  params: {
    devCenterName: name
  }
  dependsOn: [
    configureDevCenterNetworkConnection
    configureDevCenterComputeGallery
  ]
}

@description('Dev Center Projects')
module createDevCenterProjects 'createDevCenterProjects.bicep' = [
  for project in projects: {
    name: '${project.name}-Project'
    params: {
      devCenterName: name
      networkConnectionName: project.networkConnectionName
      devBoxDefinitionBackEndName: configureDevBoxDefinitions.outputs.devBoxDefinitionBackEndName
      devBoxDefinitionFrontEndName: configureDevBoxDefinitions.outputs.devBoxDefinitionFrontEndName
      tags: tags
      projectInfo: project
    }
    dependsOn: [
      configureDevBoxDefinitions
    ]
  }
]
