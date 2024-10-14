param name string
param devCenterName string
param networkConnectionName string
param devBoxDefinitionBackEndName string
param devBoxDefinitionFrontEndName string
param tags object


resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
} 

@description('Create DevCenter eShop Project')
resource devCenterPproject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    devCenterId: deployDevCenter.id
    maxDevBoxesPerUser: 10
  }
  tags:tags
}

output projectId string = devCenterPproject.id
output projectName string = devCenterPproject.name

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'backEndPool'
  location: resourceGroup().location
  parent: devCenterPproject
  properties: {
    devBoxDefinitionName: devBoxDefinitionBackEndName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkConnectionName
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Disabled'
    }
  }
}

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource frontEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'frontEndPool'
  location: resourceGroup().location
  parent: devCenterPproject
  properties: {
    devBoxDefinitionName: devBoxDefinitionFrontEndName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkConnectionName
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Disabled'
    }
  }
}
