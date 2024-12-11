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

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: '${uniqueString(resourceGroup().id, name)}-devcenter'
  location: location
  tags: tags
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: catalogItemSyncEnableStatus
    }
    networkSettings:{
      microsoftHostedNetworkEnableStatus: microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings:{
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
