/*
.SYNOPSIS
Creating a serverfarms (AppService Plan) instance with the given specs.
.DESCRIPTION
Creating a serverfarms (AppService Plan) instance with the given specs.
.EXAMPLE
<pre>
module webApp 'br:contosoregistry.azurecr.io/web/serverfarms:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'serverfarms')
  params: {
    appServicePlanName: 'AspName'
  }
}
</pre>
<p>Creates a WebApp with the name 'webAppName'</p>
.LINKS
- [Bicep Microsoft.Web Serverfarms ](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep)
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
*/

// ================================================= Parameters =================================================
@description('The resourcename for the app service plan to upsert.')
@minLength(1)
@maxLength(40)
param appServicePlanName string

@description('''
The sku object for this app service plan. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep#skudescription.
Defaults to:
{
  name: 'P1v3'
  capacity: 1
}
Valid SKU names (at the time of writing) are: B1, B2, B3, D1, F1, FREE, I1, I1v2, I2, I2v2, I3, I3v2, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, S1, S2, S3, SHARED, WS1, WS2, WS3
''')
param appServicePlanSku object = {
  name: 'P1v3'
  capacity: 1
}

// TODO: Check values (i assumed windows to be a valid value --> can't find docs on this).
@description('The OS type for this app service plan.')
@allowed([
  ''
  'linux'
  'windows'
])
param appServicePlanOsType string = 'linux'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
If true, apps assigned to this App Service plan can be scaled independently.
If false, apps assigned to this App Service plan will scale to all instances of the plan.
''')
param appServicePlanPerSiteScaling bool = true

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan')
param appServicePlanMaximumElasticWorkerCount int?

@description('If set to true, this App Service Plan will perform availability zone balancing.')
param zoneRedundant bool = false


// ================================================= Resources =================================================
@description('Upsert the app service plan with the given parameters.')
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: appServicePlanOsType == 'linux' ? true : false //According to MS Docs: If Linux app service plan true, false otherwise.
    perSiteScaling: appServicePlanPerSiteScaling
    maximumElasticWorkerCount: appServicePlanMaximumElasticWorkerCount ?? 1 // Only required if the app service plan is a elastic plan (function app). Default to 1.
    zoneRedundant: zoneRedundant
  }
  sku: appServicePlanSku
  kind: appServicePlanOsType
}

// ================================================= Outputs =================================================
@description('Output the App Service Plan\'s resource id.')
output appServicePlanResourceId string = appServicePlan.id
@description('Output the App Service Plan\'s SKU name.')
output appServicePlanSkuName string = appServicePlan.sku.name
@description('Output the App Service Plan\'s resource name.')
output appServicePlanResourceName string = appServicePlan.name
