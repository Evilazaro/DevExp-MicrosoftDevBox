@description('DevCenter Name')
param devCenterName string

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Existent Compute Gallery')
resource computeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' existing = {
  parent: devCenter
  name: 'Default'
}

@description('Deploy a DevBox Image Definition for BackEnd Engineer')
resource backEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: computeGallery
  name: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

@description('Output the BackEnd Image Id')
output backEndImageId string = backEndImage.id

@description('Tags for BackEnd Engineer')
var tagsBackEnd = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  landingZone: 'DevBox'
  devBoxDefinition: 'PetDx-BackEndEngineer'
}

@description('Create DevCenter DevBox Definition for BackEnd Engineer')
resource devBoxDefinitionBackEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'PetDx-BackEndEngineer'
  location: resourceGroup().location
  parent: devCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: backEndImage.id
    }
    osStorageType: 'ssd_512gb'
    sku: {
      capacity: 10
      family: 'string'
      name: 'general_i_32c128gb512ssd_v2'
    }
  }
 tags: tagsBackEnd
}

output devBoxDefinitionBackEndId string = devBoxDefinitionBackEnd.id
output devBoxDefinitionBackEndName string = devBoxDefinitionBackEnd.name

@description('Deploy a DevBox Image Definition for FrontEnd Engineer')
resource frontEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: computeGallery
  name: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
}

@description('Output the FrontEnd Image Id')
output frontEndImageId string = frontEndImage.id

@description('Tags for FrontEnd Engineer')
var tagsFrontEnd = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  landingZone: 'DevBox'
  devBoxDefinition: 'PetDx-FrontEndEngineer'
}

@description('Create DevCenter DevBox Definition for FrontEnd Engineer')
resource devBoxDefinitionFrontEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'PetDx-FrontEndEngineer'
  location: resourceGroup().location
  parent: devCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: frontEndImage.id
    }
    osStorageType: 'ssd_512gb'
    sku: {
      capacity: 10
      family: 'string'
      name: 'general_i_32c128gb512ssd_v2'
    }
  }
  tags: tagsFrontEnd
}

output devBoxDefinitionFrontEndId string = devBoxDefinitionFrontEnd.id
output devBoxDefinitionFrontEndName string = devBoxDefinitionFrontEnd.name
