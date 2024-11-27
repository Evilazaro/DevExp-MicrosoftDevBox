param devCenterName string
param networkConnectionName string
param devBoxDefinitionBackEndName string
param devBoxDefinitionFrontEndName string
param projectInfo object
param tags object

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Create DevCenter eShop Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: projectInfo.name
  location: resourceGroup().location
  properties: {
    devCenterId: devCenter.id
    maxDevBoxesPerUser: 10
    description: projectInfo.description
    displayName: projectInfo.name
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
        'ImageDefinition'
      ]
    }
  }
  dependsOn: [
    devCenter
  ]
  tags: tags
}

@description('Create DevCenter Catalogs with DevBox Tasks')
module projectCatalog 'configureProjectCatalogs.bicep' = {
  name: '${projectInfo.name}-catalog'
  params: {
    projectInfo: projectInfo
  }
  dependsOn: [
    project
  ]
}

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  name: 'backEndPool'
  location: resourceGroup().location
  parent: project
  properties: {
    devBoxDefinitionName: devBoxDefinitionBackEndName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkConnectionName
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
    stopOnNoConnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
    singleSignOnStatus: 'Enabled'
    virtualNetworkType: 'Unmanaged'
  }
}

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource frontEndPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  name: 'frontEndPool'
  location: resourceGroup().location
  parent: project
  properties: {
    devBoxDefinitionName: devBoxDefinitionFrontEndName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkConnectionName
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
    stopOnNoConnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
    singleSignOnStatus: 'Enabled'
    virtualNetworkType: 'Unmanaged'
  }
}
