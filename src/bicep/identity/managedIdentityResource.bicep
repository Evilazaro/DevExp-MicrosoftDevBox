@description('Workload Name')
param workloadName string 

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: workloadName
  location: resourceGroup().location
}