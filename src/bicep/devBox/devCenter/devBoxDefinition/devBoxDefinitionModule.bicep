@description('Dev Center Name')
param devCenterName string

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
      solution: devCenterName
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
      solution: devCenterName
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
      solution: devCenterName
      landingZone: 'DevBox'
    }
  }
]

module devBoxDefinition 'devBoxDefinitionResource.bicep' = [
  for devBoxDefinition in devBoxDefinitions: {
    name: devBoxDefinition.name
    scope:resourceGroup()
    params: {
      devCenterName: devCenterName
      name: devBoxDefinition.name
      sku: devBoxDefinition.sku
      tags: devBoxDefinition.tags
      hibernateSupport: devBoxDefinition.sku.hibernateSupport
    }
  }
]
