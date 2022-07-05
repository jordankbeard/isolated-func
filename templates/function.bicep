@description('Name of the application')
param appName string

@description('The function runtime')
param functionWorkerRuntime string

@description('Location of the datacentre hosting the function')
param location string = resourceGroup().location

@description('Storage account name, gloablly unique')
param storageAccountName string

@description('Storage account key')
param storageAccountKey string

@description('Database connection string')
param dbConnectionString string

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountKey}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountKey}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(appName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'CosmosDbConnectionString'
          value: dbConnectionString
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
