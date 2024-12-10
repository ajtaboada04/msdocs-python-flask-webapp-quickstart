@description('Name of the Azure Container Registry')
param name string

@description('Location for the Azure Container Registry')
param location string = resourceGroup().location

@description('Enable admin user')
param acrAdminUserEnabled bool = true

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output acrLoginServer string = containerRegistry.properties.loginServer
output acrName string = containerRegistry.name
