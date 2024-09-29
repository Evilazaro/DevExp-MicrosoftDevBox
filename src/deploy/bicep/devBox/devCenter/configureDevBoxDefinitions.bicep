param devCenterName string

resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

resource defaultComputeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' existing = {
  parent: deployDevCenter
  name: 'Default'
}

output defaultComputeGalleryId string = defaultComputeGallery.id
output defaultComputeGalleryName string = defaultComputeGallery.name

resource backEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: defaultComputeGallery
  name: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

output backEndImageId string = backEndImage.id

@description('Create DevCenter DevBox Definition for BackEnd Engineer')
resource devBoxDefinitionBackEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-BackEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
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
}

output devBoxDefinitionBackEndId string = devBoxDefinitionBackEnd.id
output devBoxDefinitionBackEndName string = devBoxDefinitionBackEnd.name

resource frontEndImage 'Microsoft.DevCenter/devcenters/galleries/images@2024-02-01' existing = {
  parent: defaultComputeGallery
  name: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
}

output frontEndImageId string = frontEndImage.id

@description('Create DevCenter DevBox Definition for FrontEnd Engineer')
resource devBoxDefinitionFrontEnd 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: 'eShopPet-FrontEndEngineer'
  location: resourceGroup().location
  parent: deployDevCenter
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
}

output devBoxDefinitionFrontEndId string = devBoxDefinitionFrontEnd.id
output devBoxDefinitionFrontEndName string = devBoxDefinitionFrontEnd.name
