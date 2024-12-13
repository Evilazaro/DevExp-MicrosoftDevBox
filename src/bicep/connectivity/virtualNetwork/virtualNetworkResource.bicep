@description('Virtual Network Name')
param name string

@description('Virtual Network Location')
param location string

@description('Virtual Network Address Prefixes')
param addressPrefixes array

@description('Subnets')
param subnets array

@description('Enable DDoS Protection Plan')
param enableDdosProtection bool = false

@description('DDoS Protection Plan Resource ID')
param ddosProtectionPlanId string

@description('Tags')
param tags object

@description('Virtual Network Resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'Vnet-${uniqueString(resourceGroup().id, name)}'
  location: location
  tags: tags
  properties:{
    addressSpace:{
      addressPrefixes:addressPrefixes
    }
    enableDdosProtection: enableDdosProtection ? true : false
    ddosProtectionPlan: enableDdosProtection ? {
      id: ddosProtectionPlanId
    } : null
    subnets:[for (subnet,i) in subnets: {
      name: subnet.name
      properties:{
        addressPrefix: '10.0.${i}.0/24'
      }
    }]
  }
}

@description('Virtual Network Resource ID')
output virtualNetworkId string = virtualNetwork.id

@description('Virtual Network Resource Name')
output virtualNetworkName string = virtualNetwork.name

@description('Virtual Network Resource Address Prefixes')
output virtualNetworkAddressPrefixes array = virtualNetwork.properties.addressSpace.addressPrefixes

@description('Virtual Network Resource Subnets')
output virtualNetworkSubnets array = virtualNetwork.properties.subnets
