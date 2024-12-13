@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Tags')
param tags object

@description('Project Catalog Info')
param projectCatalogInfo object

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

@description('Dev Center Project Resource ID')
output devCenterProjectId string = devCenterProject.id

@description('Dev Center Project Resource Name')
output devCenterProjectName string = devCenterProject.name

output devCenterProjectLocation string = devCenterProject.location

output devCenterProjectTags object = devCenterProject.tags


@description('Project Catalog Resource')
resource projectCatalog 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = {
  name: '${name}-Catalog'
  parent: devCenterProject
  properties: {
    gitHub: {
      uri: projectCatalogInfo.uri
      branch: projectCatalogInfo.branch
      path: projectCatalogInfo.path
    }
    syncType: 'Scheduled'
  }
}
