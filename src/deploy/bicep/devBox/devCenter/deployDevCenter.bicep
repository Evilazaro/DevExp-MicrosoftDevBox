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
