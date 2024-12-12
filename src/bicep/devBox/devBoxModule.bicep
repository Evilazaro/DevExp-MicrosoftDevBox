@description('Workload Name')
param workloadName string

@description('Network Connection Resource Group Name')
param networkConnectionResourceGroupName string

@description('Network Connections')
param networkConnections array

@description('Catalog Item Sync Enable Status')
var catalogItemSyncEnableStatus = 'Enabled'

@description('Microsoft Hosted Network Enable Status')
var microsoftHostedNetworkEnableStatus = 'Enabled'

@description('Install Azure Monitor Agent Enable Status')
var installAzureMonitorAgentEnableStatus = 'Enabled'


@description('Tags')
var tags = {
  division: 'PlatformEngineeringTeam-DevEx'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: workloadName
  landingZone: 'DevBox'
}
@description('Deploy Dev Center resource to Azure')
module deployDevCenter 'devCenter/devCenterResource.bicep' = {
  name: 'DevCenter'
  scope: resourceGroup()
  params: {
    name: workloadName
    tags: tags
    location: resourceGroup().location
    catalogItemSyncEnableStatus: catalogItemSyncEnableStatus
    microsoftHostedNetworkEnableStatus: microsoftHostedNetworkEnableStatus
    installAzureMonitorAgentEnableStatus: installAzureMonitorAgentEnableStatus
  }
}

@description('Attach Dev Center to Network Connection')
module networkConnectionAttachment 'devCenter/connectivity/networkConnectionAttachmentResource.bicep' = [
  for networkConnection in networkConnections: {
    name: networkConnection
    params: {
      devCenterName: deployDevCenter.outputs.devCenterName
      name: networkConnection
      networkConnectionResourceGroupName: networkConnectionResourceGroupName
    }
  }
]

@description('Configure Environment Types')
module environmentTypes 'devCenter/environmentConfiguration/environmentTypeModule.bicep' = {
  name: 'EnvironmentTypes'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}


@description('Configure Catalogs')
module catalogs 'devCenter/environmentConfiguration/catalogModule.bicep' = {
  name: 'Catalogs'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
  }
}


@description('Dev Box Definitions')
var devBoxDefinitions = [
  {
    name: 'backend-Engineer'
    sku: {
      name: 'general_i_32c128gb512ssd_v2'
      imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
      hibernateSupport: 'Disabled'
    }
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: deployDevCenter.outputs.devCenterName
      landingZone: 'DevBox'
    }
  }
  {
    name: 'frontEnd-Engineer'
    sku: {
      name: 'general_i_16c64gb256ssd_v2'
      imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
      hibernateSupport: 'Enabled'
    }
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: deployDevCenter.outputs.devCenterName
      landingZone: 'DevBox'
    }
  }
  {
    name: 'web-designer'
    sku: {
      name: 'general_i_16c64gb256ssd_v2'
      imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
      hibernateSupport: 'Enabled'
    }
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: deployDevCenter.outputs.devCenterName
      landingZone: 'DevBox'
    }
  }
]

@description('Deploy DevBox Definitions')
module devBoxDefinition 'devCenter/devBoxDefinition/devBoxDefinitionModule.bicep' = {
  name: 'DevBoxDefinition'
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
    devBoxDefinitions: devBoxDefinitions
  }
}

@description('Projects')
var projects = [
  {
    name: 'eShop'
    networkConnectionName: networkConnections[0]
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'DevBox'
      landingZone: 'eShop'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnectionName: networkConnections[1]
    tags: {
      division: 'PlatformEngineeringTeam-DevEx' 
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'Contoso Traders'
      landingZone: 'DevBox'
    }
  }
  {
    name: 'DevExBox'
    networkConnectionName: networkConnections[2]
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'DevBox'
      landingZone: 'DevBox'
    }
  }
]

@description('Configure Projects')
module devCenterprojects 'devCenter/management/devCenterProjectModule.bicep' = {
  name: 'Projects'
  scope: resourceGroup()
  params: {
    devCenterName: deployDevCenter.outputs.devCenterName
    projects: projects
  }
  dependsOn:  [
    devBoxDefinition
  ]
}

@description('Dev Box Pool')
module devBoxPools 'devCenter/management/devBoxPool/devCenterPoolModule.bicep' = {
  name: 'DevBoxPools'
  scope: resourceGroup()
  params: {
    projects: projects
    devBoxDefinitions: devBoxDefinitions
  }
  dependsOn: [
    devBoxDefinition
    devCenterprojects
  ]
}
