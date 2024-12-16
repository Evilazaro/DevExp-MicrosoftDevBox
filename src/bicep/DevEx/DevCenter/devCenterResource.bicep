@description('Dev Center name')
param name string

@description('Location')
param location string

@description('Catalog Item Sync Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param catalogItemSyncEnableStatus string

@description('Microsoft Hosted Network Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param microsoftHostedNetworkEnableStatus string

@description('Install Azure Monitor Agent Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param installAzureMonitorAgentEnableStatus string

@description('Tags')
param tags object

@description('Custom Role Info')
param customRoleInfo object

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: '${uniqueString(resourceGroup().id, name)}-devcenter'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: installAzureMonitorAgentEnableStatus
    }
  }
}

@description('DevCenter Resource ID')
output devCenterId string = devCenter.id

@description('DevCenter Resource Name')
output devCenterName string = devCenter.name

@description('DevCenter Resource Location')
output devCenterLocation string = devCenter.location

@description('DevCenter Resource Catalog Item Sync Enable Status')
output devCenterCatalogItemSyncEnableStatus string = devCenter.properties.projectCatalogSettings.catalogItemSyncEnableStatus

@description('DevCenter Resource Microsoft Hosted Network Enable Status')
output devCenterMicrosoftHostedNetworkEnableStatus string = devCenter.properties.networkSettings.microsoftHostedNetworkEnableStatus

@description('DevCenter Resource Install Azure Monitor Agent Enable Status')
output devCenterInstallAzureMonitorAgentEnableStatus string = devCenter.properties.devBoxProvisioningSettings.installAzureMonitorAgentEnableStatus

@description('DevCenter Resource Tags')
output devCenterTags object = devCenter.tags

module roleAssignment '../../identity/roleAssignmentResource.bicep' = {
  name: 'roleAssignment'
  scope: subscription()
  params: {
    principalId: devCenter.identity.principalId
    roleDefinitionIds: [
      customRoleInfo.id
      '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
      '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
      '45d50f46-0b78-4001-a660-4198cbe8cd05'
    ]
  }
}
