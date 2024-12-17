resource firewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
  name: 'myFirewall'
  location: resourceGroup().location
  properties:{

  }
}
