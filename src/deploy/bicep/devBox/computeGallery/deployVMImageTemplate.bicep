param computeGalleryName string
param userIdentityName string

resource computeGallery 'Microsoft.Compute/galleries@2023-07-03' existing = {
  name: computeGalleryName
}

resource userIdentity 'Microsoft.ManagedIdentity/identities@2023-07-31-preview' existing = {
  name: userIdentityName
} 

resource backEndEngineerImageDefinition 'Microsoft.Compute/galleries/images@2023-07-03' = {
  name: 'backEndEngineerImageDefinition'
  location: resourceGroup().location
  parent: computeGallery
  properties: {
    architecture: 'string'
    description: 'string'
    disallowed: {
      diskTypes: [
        'string'
      ]
    }
    identity: {
      type: 'UserAssigned'
      identityIds: [
        userIdentity.id
      ]
    }
    endOfLifeDate: 'string'
    eula: 'string'
    features: [
      {
        name: 'string'
        value: 'string'
      }
    ]
    hyperVGeneration: 'string'
    identifier: {
      offer: 'visualstudioplustools'
      publisher: 'microsoftvisualstudio'
      sku: 'vs-2022-ent-general-win11-m365-gen2'
    }
    osState: 'string'
    osType: 'string'
    privacyStatementUri: 'string'
    purchasePlan: {
      name: 'string'
      product: 'string'
      publisher: 'string'
    }
    recommended: {
      memory: {
        max: int
        min: int
      }
      vCPUs: {
        max: int
        min: int
      }
    }
    releaseNoteUri: 'string'
  }
}
