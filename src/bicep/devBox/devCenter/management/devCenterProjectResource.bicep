@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string
@description('Dev Box Definitions')
param devBoxDefinitions array

@description('Tags')
param tags object

@description('Network Connection Name')
param networkConnectionName string

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview'existing = {
  name: devCenterName
  scope:resourceGroup()
}

@description('Dev Center Project Resource')
resource devCenterProject 'Microsoft.DevCenter/projects@2024-10-01-preview'= {
  name: name
  location: resourceGroup().location
  properties:{
    displayName: name
    devCenterId: devCenter.id
  }
  tags:tags
}

@description('Dev Center Project Resource ID')
output devCenterProjectId string = devCenterProject.id

@description('Dev Center Project Resource Name')
output devCenterProjectName string = devCenterProject.name

module devBoxPool 'devBoxPool/devBoxPoolResource.bicep' = [for devBoxDefinition in devBoxDefinitions: {
  name: 'DevBoxPool-${devBoxDefinition.name}-${name}'
  params: {
    projectName: name
    devBoxDefinitionName: devBoxDefinition.name
    name: 'DevBoxPool-${devBoxDefinition.name}-${name}'
    networkConnectionName: networkConnectionName
  }
}]
