param customRoleName string
param identityId string
param customRoleId string

resource customRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, customRoleName)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: customRoleId
    principalId: identityId
    principalType: 'ServicePrincipal'
  } 
}

output customRoleAssignmentName string = customRoleAssignment.name
output customRoleAssignmentId string = customRoleAssignment.id
output customRoleAssignmentScope string = customRoleAssignment.properties.scope
output customRoleAssignmentPrincipalId string = customRoleAssignment.properties.principalId
output customRoleAssignmentRoleDefinitionId string = customRoleAssignment.properties.roleDefinitionId
