
@description('Custom Role Name')
param customRoleName string

@description('Identity Principal Id')
param identityId string

@description('Custom Role ID')
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
