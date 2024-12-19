@description('Workload Name')
param workloadName string

@description('Identity Name')
param roleDefinitionIds array = []

@description('Network Connections')
param networkConnectionsCreated array = []

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object = {}

@description('Projects')
param contosoProjectsInfo array = [
  {
    name: 'eShop'
    networkConnectionName: networkConnectionsCreated[0].name
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
    networkConnectionName: networkConnectionsCreated[1].name
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


@description('Tags')
param tags object = {
  workload: workloadName
  landingZone: 'DevEx'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Environment Types Info')
param environmentTypesInfo array = []

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo array = []

@description('Dev Center Resource')
module devCenter 'DevCenter/devCenterResource.bicep' = {
  name: 'devCenter'
  scope: resourceGroup()
  params: {
    name: workloadName
    location: resourceGroup().location
    catalogItemSyncEnableStatus: 'Enabled'
    microsoftHostedNetworkEnableStatus: 'Enabled'
    installAzureMonitorAgentEnableStatus: 'Enabled'
    tags: tags
  }
}

@description('Role Assignment Resource')
module roleAssignment '../identity/roleAssignmentResource.bicep' = {
  name: 'roleAssignment'
  scope: subscription()
  params: {
    principalId: devCenter.outputs.devCenterPrincipalId
    roleDefinitionIds: roleDefinitionIds
  }
}

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachmentResource.bicep' = {
  name: 'networkAttachments'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    networkConnectionsCreated: networkConnectionsCreated
  }
}

@description('Environment Type Resource')
module environmentTypes 'DevCenter/EnvironmentConfiguration/environmentTypesResource.bicep' = [
  for environmentType in environmentTypesInfo: {
    name: '${environmentType.name}-environmentType'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      name: environmentType.name
      tags: tags
    }
    dependsOn: [
      networkConnectionAttachment
      roleAssignment
    ]
  }
]


@description('Contoso Dev Center Catalog')
module contosoDevCenterCatalog 'DevCenter/EnvironmentConfiguration/devCentercatalogsResource.bicep' = {
  name: 'devCenterCatalog'
  scope: resourceGroup()
  params: {
    name: contosoDevCenterCatalogInfo.name
    tags: tags
    branch: contosoDevCenterCatalogInfo.branch
    devCenterName: devCenter.outputs.devCenterName
    path: contosoDevCenterCatalogInfo.path
    syncType: contosoDevCenterCatalogInfo.syncType
    type: contosoDevCenterCatalogInfo.type
    uri: contosoDevCenterCatalogInfo.uri
  }
  dependsOn: [
    networkConnectionAttachment
    roleAssignment
  ]
}

@description('Dev Center Dev Box Definitions')
module devCenterDevBoxDefinitions 'DevCenter/EnvironmentConfiguration/devBoxDefinitionResource.bicep' = {
  name: 'devBoxDefinitions'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    devBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
  }
  dependsOn: [
    networkConnectionAttachment
    roleAssignment
  ]
}

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'DevCenter/Management/projectResource.bicep' = [
  for project in contosoProjectsInfo: {
    name: '${project.name}-project'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      name: project.name
      tags: project.tags
      projectCatalogsInfo: project.catalogs
      devBoxDefinitions: devCenterDevBoxDefinitions.outputs.devBoxDefinitions
      networkConnectionName: project.networkConnectionName
      roleDefinitionIds: roleDefinitionIds
      //projectEnvironmentTypesInfo: environmentTypesInfo
    }
    dependsOn: [
      networkConnectionAttachment
      roleAssignment
    ]
  }
]
