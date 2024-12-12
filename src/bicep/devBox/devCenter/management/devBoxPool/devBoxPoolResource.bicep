@description('Project Name')
param projectName string

@description('Dev Box Definition Name')
param devBoxDefinitions array

@description('Network Connection Name')
param networkConnectionName string

@description('Project Resource')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
  scope: resourceGroup()
}

@description('Dev Box Pool Resource')
resource deployDevBoxPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for devBoxDefinition in devBoxDefinitions: {
    name: '${projectName}-${devBoxDefinition.name}-pool'
    location: resourceGroup().location
    parent: project
    properties: {
      devBoxDefinitionName: devBoxDefinition.name
      displayName: '${projectName}-${devBoxDefinition.name}-pool'
      networkConnectionName: networkConnectionName
      localAdministrator: 'Enabled'
      singleSignOnStatus: 'Enabled'
      virtualNetworkType: 'Unmanaged'
      licenseType: 'Windows_Client'
    }
  }
]
