@description('Workload Name')
param workloadName string

resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid('ContosoDevCenterDevBoxRole',workloadName)
  properties: {
    assignableScopes: [
      subscription().id
      resourceGroup().id
    ]
    roleName: 'ContosoDevCenterDevBoxRole'
    type: 'CustomRole'
    description: 'Contoso Dev Center Dev Box Role'
    permissions: [
      {
        actions: [
          'Microsoft.DevCenter/devcenters/*/read'
          'Microsoft.DevCenter/devcenters/*/write'
          'Microsoft.DevCenter/devcenters/*/delete'
          'Microsoft.DevCenter/devcenters/galleries/*/read'
          'Microsoft.DevCenter/devcenters/galleries/*/write'
          'Microsoft.DevCenter/devcenters/galleries/*/delete' 
          'Microsoft.DevCenter/devcenters/devboxdefinitions/*/read'
          'Microsoft.DevCenter/devcenters/devboxdefinitions/*/write'
          'Microsoft.DevCenter/devcenters/devboxdefinitions/*/delete'
          'Microsoft.DevCenter/devcenters/catalogs/*/read'
          'Microsoft.DevCenter/devcenters/catalogs/*/write'
          'Microsoft.DevCenter/devcenters/catalogs/*/delete'
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

@description('Custom Role Actions')
output customRoleActions array = customRole.properties.permissions



