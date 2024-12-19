@description('Workload Name')
param workloadName string 

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string 

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object = {
  name: 'Contoso-Custom-Tasks'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/customizations/tasks'
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
    name: 'Contoso-BackEnd-Engineer'
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
    name: 'Contoso-FrontEnd-Engineer'
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

@description('Deploy Identity Resources')
module identityResources '../src/bicep/identity/identityModule.bicep' = {
  name: 'identity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    connectivityResourceGroupName: connectivityResourceGroupName
  }
}

@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/devExWorkload.bicep' = {
  name: 'devBox'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
    roleDefinitionIds: identityResources.outputs.roleDefinitionIds
    contosoDevCenterCatalogInfo: contosoDevCenterCatalogInfo
    environmentTypesInfo: environmentTypesInfo
    contosoDevCenterDevBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
  }
}
