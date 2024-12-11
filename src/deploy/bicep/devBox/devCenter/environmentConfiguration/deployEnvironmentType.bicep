@description('Dev Center Name')
param devCenterName string

@description('Environment Types')
var environments = [
  {
    name: 'dev'
    tags: tags
  }
  {
    name: 'staging'
    tags: tags
  }
  {
    name: 'prod'
    tags: tags
  }
  {
    name:'UAT'
    tags: tags
  }
]

var tags = {
  idp: 'DevEx'
  source: 'InfrastructureAsCode'
  platform: 'Azure'
  versionControl: 'PlatformSourceCode'
  environmentConfiguration: 'EnvironmentType'
  environmentTypeVersion: '2024-10-01-preview'
  environmentTypeSource: 'DevCenter'
}

@description('Deploy Environment Type')
module deployEnvironmentType 'environmentTypes.bicep' = [
  for environment in environments: {
    name: environment.name
    params: {
      devCenterName: devCenterName
      name: environment.name
      tags: environment.tags
    }
  }
]

@description('Environment Type Names')
output environmentTypeNames array = [for environment in environments: environment.name]
