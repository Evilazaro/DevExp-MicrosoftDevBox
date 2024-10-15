param devCenterName string
param networkConnectionName string
param devBoxDefinitionBackEndName string
param devBoxDefinitionFrontEndName string
param projectInfo object
param tags object

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Create DevCenter eShop Project')
resource project 'Microsoft.DevCenter/projects@2024-02-01' = {
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
      ]
    }
  }
  dependsOn: [
    devCenter
  ]
  tags: tags
}

@description('Create DevCenter Catalogs with DevBox Tasks')
module projectCatalog 'configureDevCenterCatalogs.bicep' = {
  name: '${projectInfo.name}-catalog'
  params: {
    projectInfo: projectInfo
  }
  dependsOn: [
    project
  ]
}

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
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
      status: 'Disabled'
    }
  }
}

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource frontEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
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
      status: 'Disabled'
    }
  }
}
