@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Tags')
param tags object

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
