param identityName string
param location string
param tags object

resource deployIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

@description('Identity Name')
output identityName string = deployIdentity.name

@description('Identity Principal Id')
output identityPrincipalId string = deployIdentity.properties.principalId
