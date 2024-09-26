param devCenterName string
param location string
param networkConnectionName string
param identityName string
param computeGalleryName string
param networkResourceGroupName string
param logAnalyticsWorkspaceName string


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' existing = {
  name: networkConnectionName
}

resource computeGallery 'Microsoft.Compute/galleries@2021-10-01' existing = {
  name: computeGalleryName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
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
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
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

@description('Create DevCenter DevBox Definition for BackEnd Engineer')
resource devBoxDefinitionBackEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-BackEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: format(
        '/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/devcenters/{2}/galleries/Default/images/{3}',
        subscription().subscriptionId,
        resourceGroup().name,
        devCenterName,
        'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
      )
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

@description('Create DevCenter DevBox Definition for FrontEnd Engineer')
resource devBoxDefinitionFrontEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-FrontEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: format(
        '/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/devcenters/{2}/galleries/Default/images/{3}',
        subscription().subscriptionId,
        resourceGroup().name,
        devCenterName,
        'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
      )
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
resource project 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: 'eShop'
  location: resourceGroup().location
  properties: {
    description: 'eShop Commerce'
    devCenterId: deployDevCenter.id
    maxDevBoxesPerUser: 10
  }
}

output projectId string = project.id
output projectName string = project.name

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'backEndPool'
  location: resourceGroup().location
  parent: project
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
  parent: project
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
