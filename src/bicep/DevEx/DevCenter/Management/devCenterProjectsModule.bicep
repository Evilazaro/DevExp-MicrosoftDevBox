@description('Dev Center Name')
param devCenterName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'devCenterProjectResource.bicep' = [for contosoProject in contosoProjectsInfo: {
  name: 'Project-${contosoProject.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: contosoProject.name
    tags: contosoProject.tags
  }
}
]

@description('Output Contoso Dev Center Projects created')
output outPutcontosoProjectsCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
  name: contosoDevCenterProjects[i].outputs.devCenterProjectName
  id: contosoDevCenterProjects[i].outputs.devCenterProjectId
}]


// @description('Project Catalog')
// module projectCatalog 'projectCatalogResource.bicep' = [for (contosoProjectCatalog,i) in contosoProjectsInfo: {
//   name: contosoProjectCatalog[i].projectCatalog.catalogName
//   scope: resourceGroup()
//   params: {
//     projectName: contosoDevCenterProjects[i].outputs.devCenterProjectName
//     projectCatalogInfo: contosoProjectCatalog[i].projectCatalog
//   }
//   dependsOn: [
//     contosoDevCenterProjects
//   ]
// }
// ]

// @description('Output Project Catalog created')
// output projectCatalogCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
//   name: projectCatalog[i].outputs.projectCatalogName
//   id: projectCatalog[i].outputs.projectCatalogId
//   uri: projectCatalog[i].outputs.projectCatalogUri
//   branch: projectCatalog[i].outputs.projectCatalogBranch
//   path: projectCatalog[i].outputs.projectCatalogPath
// }
// ]
