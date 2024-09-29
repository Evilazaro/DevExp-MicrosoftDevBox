param devCenterName string
param networkConnectionName string
param devBoxDefinitionBackEndName string
param devBoxDefinitionFrontEndName string


resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
} 

@description('Create DevCenter eShop Project')
resource eShopProject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: 'eShop'
  location: resourceGroup().location
  properties: {
    description: 'eShop Commerce'
    devCenterId: deployDevCenter.id
    maxDevBoxesPerUser: 10
  }
}

output eShopProjectId string = eShopProject.id
output eShopProjectName string = eShopProject.name

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource backEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'backEndPool'
  location: resourceGroup().location
  parent: eShopProject
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

output backEndPoolId string = backEndPool.id
output backEndPoolName string = backEndPool.name

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource frontEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'frontEndPool'
  location: resourceGroup().location
  parent: eShopProject
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

output frontEndPoolId string = backEndPool.id
output frontEndPoolName string = backEndPool.name


@description('Create DevCenter Contoso Traders Project')
resource contosoTraders 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: 'contosoTraders'
  location: resourceGroup().location
  properties: {
    description: 'Contoso Traders'
    devCenterId: deployDevCenter.id
    maxDevBoxesPerUser: 10
  }
}

output contosoTradersId string = contosoTraders.id
output contosoTradersName string = contosoTraders.name

@description('Create DevCenter DevBox Pools for BackEnd Engineers of eShop Project')
resource contosoTradersBackEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'contosoTradersBackEndPool'
  location: resourceGroup().location
  parent: contosoTraders
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

output contosoTradersBackEndPoolId string = contosoTradersBackEndPool.id
output contosoTradersBackEndPoolName string = contosoTradersBackEndPool.name

@description('Create DevCenter DevBox Pools for FrontEnd Engineers of eShop Project')
resource contosoTradersFrontEndPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'contosoTradersFrontEndPool'
  location: resourceGroup().location
  parent: contosoTraders
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

output contosoTradersFrontEndPoolId string = contosoTradersFrontEndPool.id
output contosoTradersFrontEndPoolName string = contosoTradersFrontEndPool.name
