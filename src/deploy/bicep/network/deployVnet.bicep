param vnetName string
param subnetName string

var addressPrefixes = [
  '10.0.0.0/16'
]
var subnetPrefix = '10.0.0.0/24'

@description('Deploy Virtual Network and Subnet')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
output subnetName string = virtualNetwork.properties.subnets[0].name
output addressPrefix string = virtualNetwork.properties.subnets[0].properties.addressPrefix
output vnetName string = virtualNetwork.name

