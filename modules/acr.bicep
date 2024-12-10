param name string
param location string = resourceGroup().location
param sku string = 'Basic'
param adminUserEnabled bool = true

param keyVaultResourceId string
#disable-next-line secure-secrets-in-params
param usernameSecretName string
#disable-next-line secure-secrets-in-params
param password0SecretName string
#disable-next-line secure-secrets-in-params
param password1SecretName string


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

// Reference the existing Key Vault
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: last(split(keyVaultResourceId, '/')) // Extract the name from the resource ID
}

// Store the admin username in Key Vault
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: usernameSecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// Store the first admin password in Key Vault
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: password0SecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// Store the second admin password in Key Vault
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: password1SecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

// Output values for verification
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
