using 'identityModule.bicep'

@description('Workload Name')
param workloadName = 'myworkloadname'

@description('Workload Role Definitions Ids')
param workloadRoleDefinitionsids = [
  '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
  '45d50f46-0b78-4001-a660-4198cbe8cd05'
  '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  '18e40d4e-8d2e-438d-97e1-9528336e149c'
  'eb960402-bf75-4cc3-8d68-35b34f960f72'
]
