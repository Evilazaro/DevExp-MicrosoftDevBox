@description('Workload Name')
param workloadName string 

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string 

@description('Connectivity Info')
param contosoConnectivityInfo array

@description('Address Prefixes')
param addressPrefixes array

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object

@description('Environment Types Info')
param environmentTypesInfo array

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo array

@description('Workload Role Definitions Ids')
param workloadRoleDefinitionsids array

@description('Deploy Identity Resources')
module identityResources '../src/bicep/identity/identityModule.bicep' = {
  name: 'identity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    workloadRoleDefinitionsids: workloadRoleDefinitionsids
  }
}

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
    contosoConnectivityInfo: contosoConnectivityInfo
    addressPrefixes: addressPrefixes
  }
}

@description('Projects')
var contosoProjectsInfo = [
  {
    name: 'eShop'
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[0].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/devEx/customizations'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/devEx/environments'
      }
    ]
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'eShop'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[0].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/contosotraders.git'
        branch: 'main'
        path: '/devEx/customizations'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/contosotraders.git'
        branch: 'main'
        path: '/devEx/environments'
      }
    ]
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'Contoso-Traders'
    }
  }
]


@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/devExWorkload.bicep' = {
  name: 'devBox'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
    workloadRoleDefinitionIds: identityResources.outputs.roleDefinitionIds
    contosoDevCenterCatalogInfo: contosoDevCenterCatalogInfo
    environmentTypesInfo: environmentTypesInfo
    contosoDevCenterDevBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
    contosoProjectsInfo: contosoProjectsInfo
  }
}
