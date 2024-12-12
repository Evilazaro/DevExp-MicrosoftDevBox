@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definitions')
param devBoxDefinitions array

module deploydevBoxDefinition 'devBoxDefinitionResource.bicep' = [
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

@description('Output all devbox definitions created')
output devBoxDefinitions array = [for (devBoxDefinition,i) in devBoxDefinitions: {
  name: deploydevBoxDefinition[i].outputs.devBoxDefinitionName
  id: deploydevBoxDefinition[i].outputs.devBoxDefinitionId
  type: deploydevBoxDefinition[i].outputs.devBoxDefinitionType
  tags: deploydevBoxDefinition[i].outputs.devBoxDefinitionTags
  properties: deploydevBoxDefinition[i].outputs.devBoxDefinitionProperties
}]
