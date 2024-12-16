@description('Dev Center Name')
param principalId string

@description('Role Definition Ids')
param roleDefinitionIds array

targetScope = 'subscription'

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinitionId in roleDefinitionIds:  {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}
]
