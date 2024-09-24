param name string = ''
param vnetId string = ''
param location string = ''

resource name_resource 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: name
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: vnetId
    networkingResourceGroupName: 'NI_${name}_${location}'
  }
}
