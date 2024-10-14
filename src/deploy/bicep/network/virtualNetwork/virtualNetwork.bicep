@description('The name of the virtual network')
param name string

@description('The location of the virtual network')
param location string = resourceGroup().location

@description('The address prefix of the virtual network')
param addressPrefix array

@description('The tags of the virtual network')
param tags object

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
