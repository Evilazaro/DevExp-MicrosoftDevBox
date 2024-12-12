@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definition Name')
param name string

@description('Hibernate Support')
param hibernateSupport string

@description('Dev Box Definition SKU')
param sku object

@description('Tags for the Dev Box Definition')
param tags object

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Box Definition Resource')
resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview'= {
  name: name
  parent: devCenter
  location: resourceGroup().location
  tags: tags
  properties:{
    hibernateSupport: hibernateSupport
    imageReference: {
      id: '${resourceId('Microsoft.DevCenter/devcenters/',devCenter.name)}/galleries/default/images/${sku.imageName}'
    }
    sku: {
      name: sku.name
    }
  }
}

@description('Dev Box Definition Resource ID')
output devBoxDefinitionId string = devBoxDefinition.id

@description('Dev Box Definition Resource Name')
output devBoxDefinitionName string = devBoxDefinition.name

@description('Dev Box Definition Resource Type')
output devBoxDefinitionType string = devBoxDefinition.type

@description('Dev Box Definition Resource Tags')
output devBoxDefinitionTags object = devBoxDefinition.tags

@description('Dev Box Definition Resource Properties')
output devBoxDefinitionProperties object = devBoxDefinition.properties

