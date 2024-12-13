@description('Project Name')
param projectName string


@description('Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview'existing = {
  name: projectName
  scope: resourceGroup()
}

@description('Dev Box Pool resource')
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  name: 'devBoxPool'
  parent: project
  location: resourceGroup().location
  properties: {
    devBoxDefinitionName: 'devBoxDefinition'
    displayName: 'devBoxPool'
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    singleSignOnStatus: 'Enabled'
    networkConnectionName: 'networkConnection'
    virtualNetworkType: 'Unmanaged'
  }
}
