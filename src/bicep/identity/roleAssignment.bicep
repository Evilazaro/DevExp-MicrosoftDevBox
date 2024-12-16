@description('Dev Center Name')
param principalId string

targetScope = 'subscription'
var roleDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}
