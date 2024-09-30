param devCenterName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName  string 
param networkResourceGroupName string
param identityName string
param computeGalleryName string
param netWorkConnectionName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

@description('Deploying DevCenter')
resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    logAnalyticsWorkspace
    managedIdentity
  ]
  properties: {}
}

output devCenterId string = deployDevCenter.id
output devCenterName string = deployDevCenter.name
output devCenterIdentityId string = managedIdentity.id

module devCenterCatalogs 'configureDevCenterCatalogs.bicep' = {
  name: 'DevCenterCatalogs'
  params: {
    devCenterName: devCenterName
  }
  dependsOn: [
    deployDevCenter
  ]
}

output devCenterCatalogId string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_id
output devCenterCatalogName string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_name

module devCenterEnvironments 'configureDevCenterEnvironments.bicep' = {
  name: 'DevCenterEnvironments'
  params: {
    devCenterName: devCenterName
  }
  dependsOn: [
    devCenterCatalogs
  ]
}

output devCenterDevEnvironmentId string = devCenterEnvironments.outputs.devCenterDevEnvironmentId
output devCenterDevEnvironmentName string = devCenterEnvironments.outputs.devCenterDevEnvironmentName
output devCenterStagingEnvironmentId string = devCenterEnvironments.outputs.devCenterStagingEnvironmentId
output devCenterStagingEnvironmentName string = devCenterEnvironments.outputs.devCenterStagingEnvironmentName


module configureDevCenterNetworkConnection 'configureDevCenterNetworkConnection.bicep' = {
  name: 'DevCenterNetworkConnection'
  params: {
    devCenterName: devCenterName
    networkResourceGroupName: networkResourceGroupName
    networkConnectionName: netWorkConnectionName
  }
  dependsOn:[
    devCenterEnvironments
  ]
}

output devCenterNetworkConnectionId string = configureDevCenterNetworkConnection.outputs.devCenterName_networkConnection_id
output devCenterNetworkConnectionName string = configureDevCenterNetworkConnection.outputs.devCenterName_networkConnection_name

module configureDevCenterComputeGallery 'configureDevCenterComputeGallery.bicep' = {
  name: 'DevCenterComputeGallery'
  params: {
    devCenterName: devCenterName
    computeGalleryName: computeGalleryName
  }
  dependsOn:[
    configureDevCenterNetworkConnection
  ]
}

output devCenterComputeGalleryImageId string = configureDevCenterComputeGallery.outputs.devCenterName_computeGalleryImage_id
output devCenterComputeGalleryImageName string = configureDevCenterComputeGallery.outputs.devCenterName_computeGalleryImage_name

module configureDevBoxDefinitions 'configureDevBoxDefinitions.bicep' = {
  name: 'DevBoxDefinitions'
  params: {
    devCenterName: devCenterName
  }
  dependsOn:[
    configureDevCenterComputeGallery
  ]
}

output devBoxDefinitionBackEndId string = configureDevBoxDefinitions.outputs.devBoxDefinitionBackEndId
output devBoxDefinitionBackEndName string = configureDevBoxDefinitions.outputs.devBoxDefinitionBackEndName
output devBoxDefinitionFrontEndId string = configureDevBoxDefinitions.outputs.devBoxDefinitionFrontEndId
output devBoxDefinitionFrontEndName string = configureDevBoxDefinitions.outputs.devBoxDefinitionFrontEndName

module createDevCenterProjects 'createDevCenterProjects.bicep' = {
  name: 'DevCenterProjects'
  params: {
    devCenterName: devCenterName
    networkConnectionName: netWorkConnectionName
    devBoxDefinitionBackEndName: configureDevBoxDefinitions.outputs.devBoxDefinitionBackEndName
    devBoxDefinitionFrontEndName: configureDevBoxDefinitions.outputs.devBoxDefinitionFrontEndName
  }
  dependsOn:[
    configureDevBoxDefinitions
  ]
}

output eShopProjectId string = createDevCenterProjects.outputs.eShopProjectId
output eShopProjectName string = createDevCenterProjects.outputs.eShopProjectName
output backEndPoolId string = createDevCenterProjects.outputs.backEndPoolId
output backEndPoolName string = createDevCenterProjects.outputs.backEndPoolName
output frontEndPoolId string = createDevCenterProjects.outputs.frontEndPoolId
output frontEndPoolName string = createDevCenterProjects.outputs.frontEndPoolName
output contosoProjectId string = createDevCenterProjects.outputs.contosoTradersId 
output contosoProjectName string = createDevCenterProjects.outputs.contosoTradersName
output contosoProjectDevEnvironmentId string = createDevCenterProjects.outputs.contosoTradersBackEndPoolId
output contosoProjectDevEnvironmentName string = createDevCenterProjects.outputs.contosoTradersBackEndPoolName
output contosoProjectStagingEnvironmentId string = createDevCenterProjects.outputs.contosoTradersFrontEndPoolId
output contosoProjectStagingEnvironmentName string = createDevCenterProjects.outputs.contosoTradersFrontEndPoolName


@description('Create DevCenter Diagnostic Settings')
resource devCenterDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'devCenterDiagnosticSettings'
  scope: deployDevCenter
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
  dependsOn: [
    logAnalyticsWorkspace
    createDevCenterProjects
  ]
}

output devCenterDiagnosticSettingsId string = devCenterDiagnosticSettings.id
output devCenterDiagnosticSettingsName string = devCenterDiagnosticSettings.name
output devCenterDiagnosticSettingsWorkspaceId string = logAnalyticsWorkspace.id
output devCenterDiagnosticSettingsDevCenterId string = deployDevCenter.id 
output devCenterDiagnosticSettingsDevCenterName string = deployDevCenter.name

