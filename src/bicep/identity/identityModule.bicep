@description('Workload Name')
param workloadName string

module customRole 'customRoleResource.bicep' = {
  name: 'customRole'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

module managedIdentity 'managedIdentityResource.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

module roleAssignment 'roleAssignmentResource.bicep' = {
  name: 'roleAssignment'
  scope: subscription()
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionIds: [
      '${customRole.outputs.customRoleInfo.id}' 
      '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
      '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
      '45d50f46-0b78-4001-a660-4198cbe8cd05'
    ]
  }
}
