@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('SKU configuration for the App Service Plan')
param sku object = {
  capacity: 1
  family: 'B'
  name: 'B1'
  size: 'B1'
  tier: 'Basic'
}

@description('Kind of App Service Plan')
param kind string = 'linux'

@description('Is the plan reserved for Linux')
param reserved bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
