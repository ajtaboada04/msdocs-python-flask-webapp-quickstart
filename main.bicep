@description('Name of the Azure Container Registry')
param containerRegistryName string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container Registry Image Name')
param containerRegistryImageName string

@description('Container Registry Image Version')
param containerRegistryImageVersion string

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: containerRegistryName
}

resource acrCredentials 'Microsoft.ContainerRegistry/registries/listCredentials@2023-01-01-preview' = {
  name: 'listCredentials'
  parent: acr
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'linux'
    reserved: true
  }
}

module webApp 'modules/webApp.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettingsKeyValuePairs: {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
        DOCKER_REGISTRY_SERVER_URL: acr.properties.loginServer
        DOCKER_REGISTRY_SERVER_USERNAME: acrCredentials.properties.username
        DOCKER_REGISTRY_SERVER_PASSWORD: acrCredentials.properties.passwords[0].value
      }
    }
  }
}
