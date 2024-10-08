@description('The name of the virtual network')
param virtualNetworkName string 

@description('The location of the virtual network')
param location string = resourceGroup().location

@description('The address prefix of the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('The tags of the virtual network')
param tags object = {
  
}

@description('Deploy a virtual network to Azure')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
  tags: tags  
}

@description('The ID of the virtual network')
output virtualNetworkId string = virtualNetwork.id

@description('The name of the virtual network')
output virtualNetworkName string = virtualNetworkName

@description('Subnets of the virtual network')
output subnets array = virtualNetwork.properties.subnets
