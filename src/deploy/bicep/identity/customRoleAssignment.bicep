param customRoleName string
param identityId string
param currentUser string
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

@description('Deploy Custom Role Assignment')
resource deployDevBoxUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, 'MicrosoftDevBoxUser')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/45d50f46-0b78-4001-a660-4198cbe8cd05'
    principalId: currentUser
    principalType: 'User'
  } 
}

output deployDevBoxUserRoleAssignmentName string = deployDevBoxUserRoleAssignment.name
output deployDevBoxUserRoleAssignmentId string = deployDevBoxUserRoleAssignment.id
output deployDevBoxUserRoleAssignmentScope string = deployDevBoxUserRoleAssignment.properties.scope
output deployDevBoxUserRoleAssignmentPrincipalId string = deployDevBoxUserRoleAssignment.properties.principalId
output deployDevBoxUserRoleAssignmentRoleDefinitionId string = deployDevBoxUserRoleAssignment.properties.roleDefinitionId
