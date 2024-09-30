param solutionName string

var identityName = format('{0}-identity', solutionName)
var customRoleName = format('{0}-customRole', identityName)

module identity 'deployIdentity.bicep' = {
  name: 'deployIdentity'
  params: {
    location: resourceGroup().location
    identityName: identityName
  }
}

output identityName string = identity.outputs.identityName
output ideidentityClientIdntityId string = identity.outputs.identityClientId
output identityPrincipalId string = identity.outputs.identityPrincipalId
output identityResourceId string = identity.outputs.identityResourceId

module customRole 'deployCustomRole.bicep' = {
  name: 'deployCustomRole'
  params: {
    customRoleName: customRoleName
  }
  dependsOn: [
    identity
  ]
}

output userAssignedIdentityId string = customRole.outputs.customRoleId
output userAssignedIdentityName string = customRole.outputs.customRoleName

module identityCustomRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'identityCustomRoleAssignment'
  params: {
    customRoleName: customRole.outputs.customRoleName
    identityId: identity.outputs.identityPrincipalId
    customRoleId: customRole.outputs.customRoleId
  }
  dependsOn: [
    customRole
  ]
}

output customRoleAssignmentName string = identityCustomRoleAssignment.outputs.customRoleAssignmentName
output customRoleAssignmentId string = identityCustomRoleAssignment.outputs.customRoleAssignmentId
output customRoleAssignmentScope string = identityCustomRoleAssignment.outputs.customRoleAssignmentScope
output customRoleAssignmentPrincipalId string = identityCustomRoleAssignment.outputs.customRoleAssignmentPrincipalId
output customRoleAssignmentRoleDefinitionId string = identityCustomRoleAssignment.outputs.customRoleAssignmentRoleDefinitionId
