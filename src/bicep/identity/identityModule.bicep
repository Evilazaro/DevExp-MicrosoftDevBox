@description('Workload Name')
param workloadName string

@description('Workload Role Definitions Ids')
param workloadRoleDefinitionsids array 

module customRole 'customRoleResource.bicep' = {
  name: 'customRole'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Custom Role Name')
output customRoleName string = customRole.outputs.customRoleName

var customRoleArray = [customRole.outputs.customRoleName]

var roleDefinitionIds = union(workloadRoleDefinitionsids, customRoleArray) 

module managedIdentity 'managedIdentityResource.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Managed Identity Role Assignment')
module roleAssignment 'roleAssignmentResource.bicep' = {
  scope: subscription()
  name: 'managedIdentityRoleAssignment'
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionIds: roleDefinitionIds
  }
}

@description('Role Definition Ids')
output roleDefinitionIds array = roleDefinitionIds
