@description('Workload Name')
param workloadName string

@description('Identity Name')
param customRoleName string = 'myCustomRole'

@description('Network Connections')
param networkConnectionsCreated array = [
  {
    name: 'eShop'
    domainJoinType: 'AzureADJoin'
    id: 'eShop'
  }
  {
    name: 'Contoso-Traders'
    domainJoinType: 'AzureADJoin'
    id: 'Contoso-Traders'
  }
]
  
@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object = {
  name: 'Contoso-Custom-Tasks'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/customizations/tasks'
}

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
param environmentTypesInfo array = [
  {
    name: 'DEV'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Dev'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'PROD'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'STAGING'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Staging'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'UAT'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Uat'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
]

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo array = [
  {
    name: 'BackEnd-Engineer'
    imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    sku: 'general_i_32c128gb512ssd_v2'
    hibernateSupport: 'Disabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'BackEnd-Engineer'
    }
  }
  {
    name: 'FrontEnd-Engineer'
    imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
    sku: 'general_i_16c64gb256ssd_v2'
    hibernateSupport: 'Enabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'FrontEnd-Engineer'
    }
  }
]

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

module roleAssignment '../identity/roleAssignmentResource.bicep' = {
  name: 'roleAssignment'
  scope: subscription()
  params: {
    principalId: devCenter.outputs.devCenterPrincipalId
    roleDefinitionIds: [
      '${customRoleName}'
      '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
      '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
      '45d50f46-0b78-4001-a660-4198cbe8cd05'
      '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
    ]
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
  }
]

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachmentResource.bicep' = {
  name: 'networkAttachments'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    networkConnectionsCreated: networkConnectionsCreated
  }
}

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
}

@description('Dev Center Dev Box Definitions')
module devCenterDevBoxDefinitions 'DevCenter/EnvironmentConfiguration/devBoxDefinitionResource.bicep' = {
  name: 'devBoxDefinitions'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    devBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
  }
  dependsOn:[
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
      //projectEnvironmentTypesInfo: environmentTypesInfo
    }
  }
]
