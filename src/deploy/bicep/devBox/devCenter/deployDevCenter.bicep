param devCenterName string
param location string
param networkConnectionName string
param identityName string
param computeGalleryName string
param networkResourceGroupName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' existing = {
  name: networkConnectionName
  scope: resourceGroup(networkResourceGroupName)
}

resource computeGallery 'Microsoft.Compute/galleries@2021-10-01' existing = {
  name: computeGalleryName
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
    networkConnection
    logAnalyticsWorkspace
    managedIdentity
  ]
  properties: {}
}

output devCenterId string = deployDevCenter.id
output devCenterName string = deployDevCenter.name
output devCenterIdentityId string = managedIdentity.id

module configureDevCenterDiagnosticSettings 'configureDevCenterDiagnosticSettings.bicep' = {
  name: 'configureDevCenterDiagnosticSettings'
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
  name: 'configureDevCenterCatalogs'
  params: {
    devCenterName: devCenterName
  }
}

output devCenterCatalogId string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_id
output devCenterCatalogName string = devCenterCatalogs.outputs.devCenterName_quickstart_devbox_tasks_name

module devCenterEnvironments 'configureDevCenterEnvironments.bicep' = {
  name: 'configureDevCenterEnvironments'
  params: {
    devCenterName: devCenterName
  }
}

output devCenterDevEnvironmentId string = devCenterEnvironments.outputs.devCenterDevEnvironmentId
output devCenterDevEnvironmentName string = devCenterEnvironments.outputs.devCenterDevEnvironmentName
output devCenterStagingEnvironmentId string = devCenterEnvironments.outputs.devCenterStagingEnvironmentId
output devCenterStagingEnvironmentName string = devCenterEnvironments.outputs.devCenterStagingEnvironmentName


module configureDevCenterNetworkConnection 'configureDevCenterNetworkConnection.bicep' = {
  name: 'configureDevCenterNetworkConnection'
  params: {
    devCenterName: devCenterName
    networkResourceGroupName: networkResourceGroupName
    networkConnectionName: networkConnectionName
  }
}

@description('Create DevCenter Compute Gallery')
resource devCenterComputeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' = {
  parent: deployDevCenter
  name: computeGallery.name
  properties: {
    galleryResourceId: resourceId('Microsoft.Compute/galleries', computeGallery.name)
  }
}

output devCenterName_computeGalleryImage_id string = devCenterComputeGallery.id
output devCenterName_computeGalleryImage_name string = devCenterComputeGallery.name

resource defaultComputeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' existing = {
  parent: deployDevCenter
  name: 'Default'
}

output defaultComputeGalleryId string = defaultComputeGallery.id
output defaultComputeGalleryName string = defaultComputeGallery.name

resource backEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: defaultComputeGallery
  name: 'visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

output backEndImageId string = backEndImage.id

@description('Create DevCenter DevBox Definition for BackEnd Engineer')
resource devBoxDefinitionBackEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-BackEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: backEndImage.id
    }
    osStorageType: 'ssd_512gb'
    sku: {
      capacity: 10
      family: 'string'
      name: 'general_i_32c128gb512ssd_v2'
    }
  }
}

output devBoxDefinitionBackEndId string = devBoxDefinitionBackEnd.id
output devBoxDefinitionBackEndName string = devBoxDefinitionBackEnd.name

resource frontEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: defaultComputeGallery
  name: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
}

output frontEndImageId string = frontEndImage.id

@description('Create DevCenter DevBox Definition for FrontEnd Engineer')
resource devBoxDefinitionFrontEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-FrontEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: frontEndImage.id
    }
    osStorageType: 'ssd_512gb'
    sku: {
      capacity: 10
      family: 'string'
      name: 'general_i_32c128gb512ssd_v2'
    }
  }
}

output devBoxDefinitionFrontEndId string = devBoxDefinitionFrontEnd.id
output devBoxDefinitionFrontEndName string = devBoxDefinitionFrontEnd.name

@description('Create DevCenter eShop Project')
resource eShopProject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: 'eShop'
  location: resourceGroup().location
  properties: {
    description: 'eShop Commerce'
    devCenterId: deployDevCenter.id
    maxDevBoxesPerUser: 10
  }
}

output eShopProjectId string = eShopProject.id
output eShopProjectName string = eShopProject.name

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'backEndPool'
  location: resourceGroup().location
  parent: eShopProject
  properties: {
    devBoxDefinitionName: devBoxDefinitionBackEnd.name
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: configureDevCenterNetworkConnection.name
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Disabled'
    }
  }
}

output backEndPoolId string = backEndPool.id
output backEndPoolName string = backEndPool.name

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource frontEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'frontEndPool'
  location: resourceGroup().location
  parent: eShopProject
  properties: {
    devBoxDefinitionName: devBoxDefinitionFrontEnd.name
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: configureDevCenterNetworkConnection.name
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Disabled'
    }
  }
}

output frontEndPoolId string = backEndPool.id
output frontEndPoolName string = backEndPool.name

// resource eShopDevEnvironment 'Microsoft.DevCenter/projects/environmentTypes@2023-04-01' = {
//   name: 'eShopDevEnvironment'
//   location: resourceGroup().location
//   tags: {
//     tagName1: 'Development'
//     tagName2: 'eShop'
//   }
//   parent: eShopProject
//   identity: {
//     type: 'string'
//     userAssignedIdentities: {}
//   }
//   properties: {
//     creatorRoleAssignment: {
//       roles: {}
//     }
//     deploymentTargetId: subscription().subscriptionId
//     status: 'Enabled'
//     userRoleAssignments: {}
//   }
// }

// output eShopDevEnvironmentId string = eShopDevEnvironment.id
// output eShopDevEnvironmentName string = eShopDevEnvironment.name

// resource eShopStagingEnvironment 'Microsoft.DevCenter/projects/environmentTypes@2023-04-01' = {
//   name: 'eShopStagingEnvironment'
//   location: resourceGroup().location
//   tags: {
//     tagName1: 'Staging'
//     tagName2: 'eShop'
//   }
//   parent: eShopProject
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${managedIdentity.id}': {}
//     }
//   }
//   properties: {
//     creatorRoleAssignment: {
//       roles: {}
//     }
//     deploymentTargetId: subscription().subscriptionId
//     status: 'Enabled'
//     userRoleAssignments: {}
//   }
// }

// output eShopStagingEnvironmentId string = eShopStagingEnvironment.id
// output eShopStagingEnvironmentName string = eShopStagingEnvironment.name
