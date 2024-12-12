@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definition Name')
param name string

@description('Tags for the Dev Box Definition')
param tags object

resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview'= {
  name: name
  location: resourceGroup().location
  properties:{
    hibernateSupport: 'Enabled'
    imageReference: {
      id: ''
    }
    osStorageType: 'StandardSSD'
    sku: {
      name: 'Standard'
      capacity: 1
      family: 'A'
      size: 'Standard_A1_v2'
      tier: 'Standard'
    }

  }
}
