param customRoleId string
param customRoleName string
param identityId string

module customRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'customRoleAssignment'
  params: {
    customRoleId: customRoleId
    customRoleName: customRoleName
    identityId: identityId
  }
}

output customRoleAssignmentName string = customRoleAssignment.name
output customRoleAssignmentId string = customRoleAssignment.outputs.customRoleAssignmentId
output customRoleAssignmentScope string = customRoleAssignment.outputs.customRoleAssignmentScope
output customRoleAssignmentPrincipalId string = customRoleAssignment.outputs.customRoleAssignmentPrincipalId
output customRoleAssignmentRoleDefinitionId string = customRoleAssignment.outputs.customRoleAssignmentRoleDefinitionId

