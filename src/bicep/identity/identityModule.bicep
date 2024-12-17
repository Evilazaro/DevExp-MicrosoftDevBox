@description('Workload Name')
param workloadName string

module customRole 'customRoleResource.bicep' = {
  name: 'customRole'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Custom Role Name')
output customRoleName string = customRole.outputs.customRoleName

module managedIdentity 'managedIdentityResource.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}
