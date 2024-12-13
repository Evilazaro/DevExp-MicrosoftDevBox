@description('DDoS Protection Plan Name')
param name string

@description('DDoS Protection Plan')
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-05-01' =  {
  name: 'ddosPlan-${uniqueString(resourceGroup().id, '${name}')}'
  location: resourceGroup().location
}

@description('DDoS Protection Plan Resource ID')
output ddosProtectionPlanId string = ddosProtectionPlan.id

@description('DDoS Protection Plan Resource Name')
output ddosProtectionPlanName string = ddosProtectionPlan.name
