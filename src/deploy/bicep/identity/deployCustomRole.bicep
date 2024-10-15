@description('Custom Role Name')
param name string

@description('Deploy Custom Role to Azure')
resource deployCustomRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
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
  }
}

@description('Custom Role Name')
output customRoleName string = deployCustomRole.name

@description('Custom Role ID')
output customRoleId string = deployCustomRole.id
