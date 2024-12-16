@description('Project Name')
param projectName string

@description('Dev Box Definition Name')
param devboxDefinitions array

@description('Network Connection Name')
param networkConnectionName string

@description('Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview'existing = {
  name: projectName
  scope: resourceGroup()
}

@description('Dev Box Pool resource')
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [for devBoxDefinition in devboxDefinitions:  {
  name: '${projectName}-${devBoxDefinition}-devBoxPool'
  parent: project
  location: resourceGroup().location
  properties: {
    devBoxDefinitionName: devBoxDefinition
    displayName: devBoxDefinition
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    singleSignOnStatus: 'Enabled'
    networkConnectionName: networkConnectionName
    virtualNetworkType: 'Unmanaged'
  }
}
]
