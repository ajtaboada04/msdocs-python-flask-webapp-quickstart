param name string
param location string
param acrAdminUserEnabled bool

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output adminUsername string = containerRegistry.properties.adminUser.username
output adminPassword string = listKeys(containerRegistry.id, '2021-06-01-preview').passwords[0].value
