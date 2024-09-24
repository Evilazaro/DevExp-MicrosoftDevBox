param identityName string
param customRoleName string
param networkResourceGroupName string

module createIdentity 'deployIdentity.bicep' = {
  name: 'deployIdentity'
  params: {
    location: resourceGroup().location
    identityName: identityName
  }
}

output identityName string = createIdentity.outputs.identityName
output ideidentityClientIdntityId string = createIdentity.outputs.identityClientId
output identityPrincipalId string = createIdentity.outputs.identityPrincipalId
output identityResourceId string = createIdentity.outputs.identityResourceId

module deployCustomRole 'deployCustomRole.bicep' = {
  name: 'deployCustomRole'
  params: {
    customRoleName: customRoleName
  }
  dependsOn: [
    createIdentity
  ]
}

output userAssignedIdentityId string = deployCustomRole.outputs.customRoleId
output userAssignedIdentityName string = deployCustomRole.outputs.customRoleName

module identityCustomRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'identityCustomRoleAssignment'
  params: {
    resourceGroupName: resourceGroup().name
    customRoleId: deployCustomRole.outputs.customRoleId
    customRoleName: deployCustomRole.outputs.customRoleName
    identityId: createIdentity.outputs.identityResourceId
  }
}

output customRoleAssignmentName string = identityCustomRoleAssignment.outputs.customRoleAssignmentName
output customRoleAssignmentId string = identityCustomRoleAssignment.outputs.customRoleAssignmentId
output customRoleAssignmentScope string = identityCustomRoleAssignment.outputs.customRoleAssignmentScope
output customRoleAssignmentPrincipalId string = identityCustomRoleAssignment.outputs.customRoleAssignmentPrincipalId
output customRoleAssignmentRoleDefinitionId string = identityCustomRoleAssignment.outputs.customRoleAssignmentRoleDefinitionId

module networkCustomRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'networkCustomRoleAssignment'
  params: {
    resourceGroupName: networkResourceGroupName
    customRoleId: deployCustomRole.outputs.customRoleId
    customRoleName: deployCustomRole.outputs.customRoleName
    identityId: createIdentity.outputs.identityResourceId
  }
}


