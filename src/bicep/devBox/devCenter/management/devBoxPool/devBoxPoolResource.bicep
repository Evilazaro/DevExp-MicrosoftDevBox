@description('Project Name')
param projectName string

@description('Dev Box Definition Name')
param devBoxDefinitionName string

@description('Network Connection Name')
param networkConnectionName string

@description('Dev Box Pool Resource Name')
param name string

@description('Project Resource')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
  scope:resourceGroup()
}

@description('Dev Box Pool Resource')
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  parent: project
  properties:{
    devBoxDefinitionName: devBoxDefinitionName
    displayName: name
    networkConnectionName: networkConnectionName
    localAdministrator:'Enabled'
    singleSignOnStatus:'Enabled'
    virtualNetworkType:'Managed'
    licenseType:'Windows_Client'
  }
} 

@description('Dev Box Pool Resource ID')
output id string = devBoxPool.id

@description('Dev Box Pool Resource Name')
output name string = devBoxPool.name

@description('Dev Box Pool Resource Properties')
output properties object = devBoxPool.properties
