@description('Dev Center Name')
param devCenterName string

@description('Hibernate Support')
var hibernateSupport = 'Enabled'

@description('Dev Box Definitions')
var devBoxDefinitions = [
  {
    name: 'backend-Engineer'
    sku: {
      name: 'general_i_32c128gb512ssd_v2'
      imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
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
    name: 'devBoxDefinition2'
    sku: {
      name: 'Standard_D4_v3'
      tier: 'Standard'
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
    params: {
      devCenterName: devCenterName
      name: devBoxDefinition.name
      sku: devBoxDefinition.sku
      tags: devBoxDefinition.tags
      hibernateSupport: hibernateSupport
    }
  }
]
