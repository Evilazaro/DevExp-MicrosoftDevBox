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
}

output devCenterDiagnosticSettingsId string = devCenterDiagnosticSettings.id
output devCenterDiagnosticSettingsName string = devCenterDiagnosticSettings.name

@description('Create DevCenter Catalogs with DevBox Tasks')
resource devCenterCatalogs 'Microsoft.DevCenter/devcenters/catalogs@2024-02-01' = {
  parent: deployDevCenter
  name: 'eShopDevCenterCatalog'
  properties: {
    gitHub: {
      uri: 'https://github.com/Evilazaro/MicrosoftDevBox.git'
      branch: 'main'
      path: 'src/customizations/tasks'
    }
  }
}

output devCenterName_quickstart_devbox_tasks_id string = devCenterCatalogs.id
output devCenterName_quickstart_devbox_tasks_name string = devCenterCatalogs.name

@description('Create DevCenter Development Environment for the eShop Project')
resource devCenterDevEnvironment 'Microsoft.DevCenter/devcenters/environmenttypes@2024-02-01' = {
  parent: deployDevCenter
  name: 'Development'
}

output devCenterDevEnvironmentId string = devCenterDevEnvironment.id
output devCenterDevEnvironmentName string = devCenterDevEnvironment.name

@description('Create DevCenter Staging Environment for the eShop Project')
resource devCenterStagingEnvironment 'Microsoft.DevCenter/devcenters/environmenttypes@2024-02-01' = {
  parent: deployDevCenter
  name: 'Staging'
}

output devCenterStagingEnvironmentId string = devCenterStagingEnvironment.id
output devCenterStagingEnvironmentName string = devCenterStagingEnvironment.name

@description('Create DevCenter Network Connection')
resource devCenterNetworkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: deployDevCenter
  name: networkConnection.name
  properties: {
    networkConnectionId: format(
      '/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/networkConnections/{2}',
      subscription().subscriptionId,
      networkResourceGroupName,
      networkConnection.name
    )
  }
}

output devCenterName_networkConnection_id string = devCenterNetworkConnection.id
output devCenterName_networkConnection_name string = devCenterNetworkConnection.name

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

resource defaultComputeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' = {
  parent: deployDevCenter
  name: 'Default'
  properties: {
    galleryResourceId: resourceId('Microsoft.Compute/galleries', 'Default')
  }
}

output devCenterName_defaultComputeGalleryImage_id string = defaultComputeGallery.id
output devCenterName_defaultComputeGalleryImage_name string = defaultComputeGallery.name

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
    networkConnectionName: devCenterNetworkConnection.name
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
    networkConnectionName: devCenterNetworkConnection.name
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
