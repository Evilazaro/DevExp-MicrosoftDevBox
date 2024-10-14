@description('DevCenter Name')
param devCenterName string

@description('Network Resource Group Name')
param networkResourceGroupName string

@description('Identity Name')
param identityName string

@description('Compute Gallery Name')
param computeGalleryName string

@description('Network Connection Name')
param netWorkConnectionName string

@description('Tags')
param tags object

@description('Managed Identity')
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
  tags: tags
  dependsOn: [
    managedIdentity
  ]
  properties: {}
}

@description('Dev Center Catalogs')
module devCenterCatalogs 'configureDevCenterCatalogs.bicep' = {
  name: 'devCenterCatalogs'
  params: {
    devCenterName: devCenterName
  }
  dependsOn: [
    deployDevCenter
  ]
}

@description('Dev Center Environments')
module devCenterEnvironments 'configureDevCenterEnvironments.bicep' = {
  name: 'devCenterEnvironments'
  params: {
    devCenterName: devCenterName
  }
  dependsOn: [
    deployDevCenter
  ]
}

@description('Dev Center Network Connection')
module configureDevCenterNetworkConnection 'configureDevCenterNetworkConnection.bicep' = {
  name: 'devCenterNetworkConnection'
  params: {
    devCenterName: devCenterName
    networkResourceGroupName: networkResourceGroupName
    networkConnectionName: netWorkConnectionName
  }
  dependsOn:[
    deployDevCenter
  ]
}

@description('Dev Center Compute Gallery')
module configureDevCenterComputeGallery 'configureDevCenterComputeGallery.bicep' = {
  name: 'devCenterComputeGallery'
  params: {
    devCenterName: devCenterName
    computeGalleryName: computeGalleryName
  }
  dependsOn:[
    deployDevCenter
  ]
}

@description('Dev Box Definitions')
module configureDevBoxDefinitions 'configureDevBoxDefinitions.bicep' = {
  name: 'DevBoxDefinitions'
  params: {
    devCenterName: devCenterName
  }
  dependsOn:[
    configureDevCenterNetworkConnection
    configureDevCenterComputeGallery
  ]
}

@description('Dev Center Projects')
module createDevCenterProjects 'createDevCenterProjects.bicep' = {
  name: 'devCenterProjects'
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
