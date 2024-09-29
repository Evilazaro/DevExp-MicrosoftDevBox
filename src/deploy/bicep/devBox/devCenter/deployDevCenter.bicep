param devCenterName string
param location string
param vNetName string
param identityName string
param computeGalleryName string
param networkResourceGroupName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName string


var netWorkConnectionName = format(vNetName, '-NetworkConnection')

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
  location: location
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

module configureDevCenterDiagnosticSettings 'configureDevCenterDiagnosticSettings.bicep' = {
  name: 'DevCenterDiagnosticSettings'
  params: {
    devCenterName: devCenterName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    managementResourceGroupName: managementResourceGroupName
  }
}

output devCenterDiagnosticSettingsId string = configureDevCenterDiagnosticSettings.outputs.devCenterDiagnosticSettingsId
output devCenterDiagnosticSettingsName string = configureDevCenterDiagnosticSettings.outputs.devCenterDiagnosticSettingsName
output devCenterDiagnosticSettingsWorkspaceId string = configureDevCenterDiagnosticSettings.outputs.devCenterDiagnosticSettingsWorkspaceId

module devCenterCatalogs 'configureDevCenterCatalogs.bicep' = {
  name: 'DevCenterCatalogs'
  params: {
    devCenterName: devCenterName
  }
}

output devCenterCatalogId string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_id
output devCenterCatalogName string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_name

module devCenterEnvironments 'configureDevCenterEnvironments.bicep' = {
  name: 'DevCenterEnvironments'
  params: {
    devCenterName: devCenterName
  }
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
}

output devCenterNetworkConnectionId string = configureDevCenterNetworkConnection.outputs.devCenterName_networkConnection_id
output devCenterNetworkConnectionName string = configureDevCenterNetworkConnection.outputs.devCenterName_networkConnection_name

module configureDevCenterComputeGallery 'configureDevCenterComputeGallery.bicep' = {
  name: 'DevCenterComputeGallery'
  params: {
    devCenterName: devCenterName
    computeGalleryName: computeGalleryName
  }
}

output devCenterComputeGalleryImageId string = configureDevCenterComputeGallery.outputs.devCenterName_computeGalleryImage_id
output devCenterComputeGalleryImageName string = configureDevCenterComputeGallery.outputs.devCenterName_computeGalleryImage_name


module configureDevBoxDefinitions 'configureDevBoxDefinitions.bicep' = {
  name: 'DevBoxDefinitions'
  params: {
    devCenterName: devCenterName
  }
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
