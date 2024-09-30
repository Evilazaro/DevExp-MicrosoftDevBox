param customRoleName string
param identityId string
param customRoleId string

@description('Deploy Custom Role Assignment')
resource deployCustomRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, customRoleName)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: customRoleId
    principalId: identityId
    principalType: 'ServicePrincipal'
  } 
}

output customRoleAssignmentName string = deployCustomRoleAssignment.name
output customRoleAssignmentId string = deployCustomRoleAssignment.id
output customRoleAssignmentScope string = deployCustomRoleAssignment.properties.scope
output customRoleAssignmentPrincipalId string = deployCustomRoleAssignment.properties.principalId
output customRoleAssignmentRoleDefinitionId string = deployCustomRoleAssignment.properties.roleDefinitionId
