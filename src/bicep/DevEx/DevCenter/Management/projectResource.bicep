@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Tags')
param tags object

@description('Project Catalog Info')
param projectCatalogInfo object

@description('Dev Box Definitions')
param devBoxDefinitions array

@description('Network Connection Name')
param networkConnectionName string

@description('Project Environment Types Info')
param projectEnvironmentTypesInfo array

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Center Project Resource')
resource devCenterProject 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  properties: {
    displayName: name
    devCenterId: devCenter.id
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
        'ImageDefinition'
      ]
    }
    maxDevBoxesPerUser: 3
    description: 'Dev Center Project - ${name}'
  }
  tags: tags
}

@description('Output Dev Center Project ID')
output devCenterProjectId string = devCenterProject.id

@description('Output Dev Center Project Name')
output devCenterProjectName string = devCenterProject.name

@description('Output Dev Center Project Tags')
output devCenterProjectTags object = devCenterProject.tags

@description('Project Catalog Resource')
resource projectCatalog 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = {
  name: '${name}-catalog'
  parent: devCenterProject
  properties: {
    gitHub: {
      uri: projectCatalogInfo.uri
      branch: projectCatalogInfo.branch
      path: projectCatalogInfo.path
    }
  }
}

@description('Project Catalog Resource ID')
output projectCatalogId string = projectCatalog.id

@description('Project Catalog Resource Name')
output projectCatalogName string = projectCatalog.name

@description('Project Catalog URI')
output projectCatalogUri string = projectCatalog.properties.gitHub.uri

@description('Project Catalog Branch')
output projectCatalogBranch string = projectCatalog.properties.gitHub.branch

@description('Project Catalog Path')
output projectCatalogPath string = projectCatalog.properties.gitHub.path

@description('Dev Center Project Pools')
resource devCenterProjectPools 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for pool in devBoxDefinitions: {
    name: '${name}-${pool.name}-pool'
    parent: devCenterProject
    location: resourceGroup().location
    properties: {
      displayName: '${name}-${pool.name}-pool'
      devBoxDefinitionName: pool.name
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      networkConnectionName: networkConnectionName
    }
  }
]

@description('Project Environment Types Resources')
resource projectEnvironmentTypes 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = [for environmentType in projectEnvironmentTypesInfo: {
  name: '${environmentType.name}-environmentType'
  parent: devCenterProject
  properties: {
    displayName: environmentType.name
    deploymentTargetId: resourceId('Microsoft.Subscription', subscription().subscriptionId)
  }  
}]
