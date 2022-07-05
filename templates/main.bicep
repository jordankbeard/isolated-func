@description('The name of the function app that you wish to create.')
param appName string

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet-isolated'
  'dotnet'
])
param runtime string = 'dotnet-isolated'

@description('The name of the database account')
param dbAccountName string = 'cosmodb${uniqueString(resourceGroup().id)}'

@description('The name of the database')
param dbName string = 'my-database'

var storageAccountName = 'azfunctions${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

module db 'db.bicep' = {
  name: 'db-${appName}'
  params: {
    accountName: dbAccountName
    databaseName: dbName
  }
}

module function 'function.bicep' = {
  name: appName
  params:{
    functionWorkerRuntime: runtime
    appName: appName
    storageAccountName: storageAccount.name
    storageAccountKey: storageAccount.listKeys().keys[0].value
    location: location
    dbConnectionString: db.outputs.connectionString
  } 
}
