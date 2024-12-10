param location string = resourceGroup().location
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string

module acr 'modules/acr.bicep' = {
  name: 'deployAcr'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'deployAppServicePlan'
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
    kind: 'Linux'
    reserved: true
  }
}

module webApp 'modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettingsKeyValuePairs: {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
        DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
        DOCKER_REGISTRY_SERVER_USERNAME: acr.outputs.adminUsername
        DOCKER_REGISTRY_SERVER_PASSWORD: acr.outputs.adminPassword
      }
    }
  }
}
