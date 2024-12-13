@description('Dev Center Name')
param devCenterName string

@description('Dev Box Definition Name')
param name string

@description('Hibernate Support')
param hibernateSupport string

@description('Image Reference ID')
param imageName string

@description('SKU Name')
param skuName string

@description('Tags')
param tags object

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Box Definition Resource')
resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    hibernateSupport: hibernateSupport
    imageReference: {
      id: '${resourceId('Microsoft.DevCenter/devcenters', devCenter.name)}/galleries/default/images/${imageName}'
    }
    sku: {
      name: skuName
    }
  }
}

@description('Dev Box Definition Resource ID')
output devBoxDefinitionId string = devBoxDefinition.id

@description('Dev Box Definition Resource Name')
output devBoxDefinitionName string = devBoxDefinition.name

@description('Dev Box Definition Image Reference ID')
output devBoxDefinitionImageReferenceId string = devBoxDefinition.properties.imageReference.id

@description('Dev Box Definition Tags')
output devBoxDefinitionTags object = devBoxDefinition.tags

