@description('Cosmos DB account name')
param accountName string

// deploying db to westus because it is not available in uk
var location = 'eastus'

@description('The name for the Core (SQL) database')
param databaseName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: toLower(accountName)
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  name: '${cosmosAccount.name}/${toLower(databaseName)}'
  properties: {
    resource: {
      id: databaseName
    }
  }
}




output connectionString string = listConnectionStrings(resourceId('Microsoft.DocumentDB/databaseAccounts', accountName), '2021-04-15').connectionStrings[0].connectionString
