param userAlias string = 'ataboada'
param location string = resourceGroup().location


// App Service Plan
param appServicePlanName string 

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan-${userAlias}'
  params: {
    name: appServicePlanName
    location: location
  }
}

// Key Vault
param keyVaultName string
param keyVaultRoleAssignments array

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault-${userAlias}'
  params: {
    name: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
  }
}

// Container Registry
param containerRegistryName string
param containerRegistryUsernameSecretName string 
param containerRegistryPassword0SecretName string 
param containerRegistryPassword1SecretName string 

module containerRegistry 'modules/acr.bicep' = {
  name: 'containerRegistry-${userAlias}'
  params: {
    name: containerRegistryName
    location: location
    keyVaultResourceId: keyVault.outputs.keyVaultId
    usernameSecretName: containerRegistryUsernameSecretName
    password0SecretName: containerRegistryPassword0SecretName
    password1SecretName: containerRegistryPassword1SecretName
  }
}

// Container App Service
param containerName string
param dockerRegistryImageName string
param dockerRegistryImageVersion string

resource keyVaultReference 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

module containerAppService 'modules/containerAppService.bicep' = {
  name: 'containerAppService-${userAlias}'
  params: {
    name: containerName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    registryName: containerRegistryName
    registryImageName: dockerRegistryImageName
    registryImageVersion: dockerRegistryImageVersion
    registryServerUserName: keyVaultReference.getSecret(containerRegistryUsernameSecretName)
    registryServerPassword: keyVaultReference.getSecret(containerRegistryPassword0SecretName)
  }
}

