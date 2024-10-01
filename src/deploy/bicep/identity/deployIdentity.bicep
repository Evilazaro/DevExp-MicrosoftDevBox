param identityName string
param location string
param tags object

resource deployIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

output identityName string = deployIdentity.name
output identityResourceId string = deployIdentity.id
output identityPrincipalId string = deployIdentity.properties.principalId
output identityClientId string = deployIdentity.properties.clientId
