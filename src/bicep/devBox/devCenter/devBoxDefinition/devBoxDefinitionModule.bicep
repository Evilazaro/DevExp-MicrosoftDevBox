@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definitions')
param devBoxDefinitions array

module devBoxDefinition 'devBoxDefinitionResource.bicep' = [
  for devBoxDefinition in devBoxDefinitions: {
    name: devBoxDefinition.name
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      name: devBoxDefinition.name
      sku: devBoxDefinition.sku
      tags: devBoxDefinition.tags
      hibernateSupport: devBoxDefinition.sku.hibernateSupport
    }
  }
]
