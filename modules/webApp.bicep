@description('Name of the Web App')
param name string

@description('Location for the Web App')
param location string = resourceGroup().location

@description('Kind of Web App')
param kind string = 'app'

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Site configuration for the Web App')
param siteConfig object = {}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
  }
}

output webAppName string = webApp.name
output webAppDefaultHostName string = webApp.properties.defaultHostName
