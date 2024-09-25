param customRoleName string

resource deployCustomRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscription().subscriptionId, customRoleName)
  properties: {
    roleName: customRoleName
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

output customRoleName string = deployCustomRole.name
output customRoleId string = deployCustomRole.id
