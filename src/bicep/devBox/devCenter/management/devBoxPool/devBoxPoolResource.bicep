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
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for devBoxDefinitionName in devBoxDefinitions: {
    name: '${projectName}-${devBoxDefinitionName}-pool'
    location: resourceGroup().location
    parent: project
    properties: {
      devBoxDefinitionName: devBoxDefinitionName
      displayName: '${projectName}-${devBoxDefinitionName}-pool'
      networkConnectionName: networkConnectionName
      localAdministrator: 'Enabled'
      singleSignOnStatus: 'Enabled'
      virtualNetworkType: 'Managed'
      licenseType: 'Windows_Client'
    }
  }
]
