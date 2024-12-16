resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(subscription().subscriptionId,'ContosoDevCenterDevBoxRole')
  properties: {
    assignableScopes: [
      '/subscriptions/${subscription().subscriptionId}'
    ]
    description: 'Contoso Dev Center Dev Box Role'
    permissions: [
      {
        actions: [
          'Microsoft.DevCenter/devcenters/*/write'
        ]
        dataActions: []
        notActions: []
        notDataActions: []
      }
    ]
  }
}

@description('Custom Role Info')
output customRoleInfo object = {
  name: customRole.name
  id: customRole.id
}
