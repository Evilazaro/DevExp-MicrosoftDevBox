@description('The name of the virtual network')
param name string

@description('The location of the virtual network')
param location string = resourceGroup().location

@description('The address prefix of the virtual network')
param addressPrefix array

@description('The tags of the virtual network')
param tags object

@description('The log analytics workspace')
param logAnalyticsName string

@description('Deploy a virtual network to Azure')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefix
    }
  }
  tags: tags
}

@description('The name of the virtual network')
output vnetName string = virtualNetwork.name

@description('Virtual Network Id')
output vnetId string = virtualNetwork.id

@description('Virtual Network IP Address Space')
output vnetAddressSpace array = virtualNetwork.properties.addressSpace.addressPrefixes

@description('Get an existent log analytics workspace')
resource logAnalyticsWorkSpace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource networkDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: virtualNetwork.name
  scope: virtualNetwork
  properties: {
    logs: [
      {
        category: 'AllLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkSpace.id
  }
}
