@description('Workload Name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Network Connections')
param networkConnections array

@description('Dev Center Catalog')
param devCenterCatalog object

@description('Tags')
var tags = {
  workload: workloadName
  landingZone: 'DevEx'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

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

@description('Environment Types Info')
var environmentTypesInfo = [
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

@description('Environment Type Resource')
module environmentTypes 'DevCenter/EnvironmentConfiguration/environmentTypesResource.bicep' = [for environmentType in environmentTypesInfo:  {
  name: 'EnvironmentTypes-${environmentType.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    name: environmentType.name
    tags: tags
  }
}
]

@description('Output Environment Types created')
output environmentTypesCreated array = [for environmentType in environmentTypesInfo: {
  name: environmentType.name
  tags: environmentType.tags
}]

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachmentResource.bicep' = [
  for (networkConnection, i) in networkConnections: {
    name: '${contosoProjectsInfo[i].name}-${networkConnection.name}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      networkConnectionResourceGroupName: connectivityResourceGroupName
      name: networkConnection.name
    }
  }
]

@description('Contoso Dev Center Catalog')
module contosoDevCenterCatalog 'DevCenter/EnvironmentConfiguration/catalogsResource.bicep' = {
  name: 'DevCenterCatalog'
  scope: resourceGroup()
  params: {
    name: devCenterCatalog.name
    tags: tags
    branch: devCenterCatalog.branch
    devCenterName: devCenter.outputs.devCenterName
    path: devCenterCatalog.path
    syncType: devCenterCatalog.syncType
    type: devCenterCatalog.type
    uri: devCenterCatalog.uri
  }
}

@description('Contoso Dev Center Dev Box Definitions')
var contosoDevCenterDevBoxDefinitionsInfo = [
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
    }
  }
]

@description('Dev Center Dev Box Definitions')
module devCenterDevBoxDefinitions 'DevCenter/EnvironmentConfiguration/devBoxDefinitionResource.bicep' = [for devBoxDefinition in contosoDevCenterDevBoxDefinitionsInfo: {
  name: devBoxDefinition.name
  scope: resourceGroup()
  params:{
    devCenterName: devCenter.outputs.devCenterName
    name: devBoxDefinition.name
    tags: devBoxDefinition.tags
    hibernateSupport: devBoxDefinition.hibernateSupport
    imageName: devBoxDefinition.imageName 
    skuName: devBoxDefinition.sku
  }
}]

@description('Output Dev Center Dev Box Definitions created')
output devBoxDefinitionsCreated array = [for (devBoxDefinition,i) in contosoDevCenterDevBoxDefinitionsInfo: {
  name: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionName
  tags: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionTags
  imageReferenceId: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionImageReferenceId
}]

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'DevCenter/Management/devCenterProjectResource.bicep' = [for contosoProject in contosoProjectsInfo: {
  name: 'Contoso-${contosoProject.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    name: contosoProject.name
    tags: tags
  }
}
]

@description('Output Contoso Dev Center Projects created')
output contosoProjectsCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
  name: contosoDevCenterProjects[i].outputs.devCenterProjectName
  id: contosoDevCenterProjects[i].outputs.devCenterProjectId
}]
