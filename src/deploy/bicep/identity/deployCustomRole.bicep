@description('Custom Role Name')
param name string

@description('Deploy Custom Role to Azure')
resource deployCustomRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(subscription().subscriptionId, name)
  properties: {
    roleName: name
    description: 'Custom role for managing custom images'
    assignableScopes: [
      resourceGroup().id
      subscription().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.DevCenter/*'
          'Microsoft.Compute/galleries/*'
          'Microsoft.Compute/galleries/images/*'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
    type: 'CustomRole'
  }
}

@description('Custom Role Name')
output customRoleName string = deployCustomRole.name

@description('Custom Role ID')
output customRoleId string = deployCustomRole.id
