@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

// @description('network connection name')
// param networkConnectionName string

// @description('Dev Box Definitions Info')
// param devBoxDefinitionsInfo array

// @description('Dev Center Project Catalog Info')
// param devCenterProjectCatalogInfo object

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
