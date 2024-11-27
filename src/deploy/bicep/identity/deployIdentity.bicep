@description('Identity Name')
param name string

@description('Identity Location')
param location string

@description('Identity Tags')
param tags object

@description('Deploy User Assigned Identity to Azure')
resource deployIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
  tags: tags
}

@description('Identity Name')
output identityName string = deployIdentity.name

@description('Identity Principal Id')
output identityPrincipalId string = deployIdentity.properties.principalId
