@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definitions Info')
param devBoxDefinitionsInfo array

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Box Definition Resource')
resource devBoxDefinitionResource 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview' = [
  for devBoxDefinition in devBoxDefinitionsInfo: {
    name: devBoxDefinition.name
    parent: devCenter
    location: resourceGroup().location
    tags: devBoxDefinition.tags
    properties: {
      hibernateSupport: devBoxDefinition.hibernateSupport
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters', devCenter.name)}/galleries/default/images/${devBoxDefinition.imageName}'
      }
      sku: {
        name: devBoxDefinition.sku
      }
    }
  }
]

@description('Dev Box Definitions created')
output devBoxDefinitions array = [
  for (devBoxDefinition, i) in devBoxDefinitionsInfo: {
    name: devBoxDefinitionResource[i].name
    id: devBoxDefinitionResource[i].id
    sku: devBoxDefinitionResource[i].properties.sku.name
    hibernateSupport: devBoxDefinitionResource[i].properties.hibernateSupport
    imageName: split(devBoxDefinitionResource[i].properties.imageReference.id, '/')[9]
    devCenterName: devCenterName
    tags: devBoxDefinitionResource[i].tags
  }
]
