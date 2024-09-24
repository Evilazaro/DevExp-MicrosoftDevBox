param identityName string
param customRoleName string

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

module deployCustomRole 'deployCustomRole.bicep' = {
  name: 'deployCustomRole'
  params: {
    customRoleName: customRoleName
  }
  dependsOn: [
    identity
  ]
}

output userAssignedIdentityId string = deployCustomRole.outputs.customRoleId
output userAssignedIdentityName string = deployCustomRole.outputs.customRoleName

module identityCustomRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'identityCustomRoleAssignment'
  params: {
    customRoleName: deployCustomRole.outputs.customRoleName
    identityId: identity.outputs.identityPrincipalId
    customRoleId: deployCustomRole.outputs.customRoleId
  }
  dependsOn: [
    deployCustomRole
  ]
}

output customRoleAssignmentName string = identityCustomRoleAssignment.outputs.customRoleAssignmentName
output customRoleAssignmentId string = identityCustomRoleAssignment.outputs.customRoleAssignmentId
output customRoleAssignmentScope string = identityCustomRoleAssignment.outputs.customRoleAssignmentScope
output customRoleAssignmentPrincipalId string = identityCustomRoleAssignment.outputs.customRoleAssignmentPrincipalId
output customRoleAssignmentRoleDefinitionId string = identityCustomRoleAssignment.outputs.customRoleAssignmentRoleDefinitionId
