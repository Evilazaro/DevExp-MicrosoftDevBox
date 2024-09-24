param customRoleName string

resource customRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
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
          'Microsoft.Compute/galleries/images/write'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/delete'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/delete'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}

output customRoleName string = customRole.name
output customRoleId string = customRole.id
