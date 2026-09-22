/*
.SYNOPSIS
Creating a serverfarms (AppService Plan) instance with the given specs.
.DESCRIPTION
Creating a serverfarms (AppService Plan) instance with the given specs.
.EXAMPLE
<pre>
module appServicePlan 'br:contosoregistry.azurecr.io/web/serverfarms:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'serverfarms')
  params: {
    appServicePlanName: 'asp-contoso-prd'
    appServicePlanSku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    appServicePlanOsType: 'functionapp'
  }
}
</pre>
<p>Creates a Linux Flex Consumption plan. Configure On Demand or Always Ready billing on the Function App module.</p>
<p>A Flex Consumption plan supports one app only, and Flex Consumption is not available in every region. Virtual network integration needs the `Microsoft.App` resource provider registered and a subnet delegated to `Microsoft.App/environments`. With `zoneRedundant: true`, configure at least two Always ready instances per group on the Function App.</p>
<p>For Flex Consumption plans, per-site scaling and maximum elastic worker count are ignored and set to null by the module.</p>
<p>For <code>app</code>, <code>functionapp</code>, and <code>elastic</code> kinds, set <code>appServicePlanReserved</code> to <code>true</code> for Linux or <code>false</code> for Windows. Explicit <code>linux</code> and <code>windows</code> kinds determine the worker OS, and Flex Consumption always uses Linux.</p>
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
Valid SKU names (at the time of writing) include: B1, B2, B3, D1, F1, FC1, FREE, I1, I1v2, I2, I2v2, I3, I3v2, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, S1, S2, S3, SHARED, WS1, WS2, WS3
For a Flex Consumption plan, specify `{ name: 'FC1', tier: 'FlexConsumption' }` and use `functionapp` for the app service plan kind.
''')
param appServicePlanSku resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.sku = {
  name: 'P1v3'
  capacity: 1
}

@description('The server farm kind. Use windows for Windows, linux for Linux, or app, functionapp, or elastic with appServicePlanReserved to select the worker operating system. Defaults to app, which uses Windows. For FC1, use functionapp because Flex Consumption always uses Linux.')
@allowed([
  'app'
  'functionapp'
  'windows'
  'linux'
  'elastic'
])
param appServicePlanOsType resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.kind = 'app'

@description('Sets the worker operating system for app, functionapp, and elastic kinds. Set to true for Linux and false for Windows. Defaults to Windows. Flex Consumption always uses Linux, and explicit linux or windows kinds take precedence.')
param appServicePlanReserved bool = false

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
This value is ignored and set to null for Flex Consumption plans.
''')
param appServicePlanPerSiteScaling bool = true

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. This value is ignored and set to null for Flex Consumption plans.')
param appServicePlanMaximumElasticWorkerCount int?

@description('If set to true, this App Service Plan will perform availability zone balancing.')
param zoneRedundant bool = false

// ================================================= Variables =================================================
@description('Indicates whether the selected SKU is the Azure Functions Flex Consumption SKU.')
var isFlexConsumption = toLower(appServicePlanSku.tier) == 'flexconsumption'
var reserved = isFlexConsumption || (toLower(appServicePlanOsType) == 'linux' || (contains([
  'app'
  'functionapp'
  'elastic'
], toLower(appServicePlanOsType)) && appServicePlanReserved))

// ================================================= Resources =================================================
@description('Upsert the app service plan with the given parameters.')
resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServicePlanSku
  kind: appServicePlanOsType
  tags: tags
  properties: {
    reserved: reserved
    perSiteScaling: isFlexConsumption ? null : appServicePlanPerSiteScaling
    maximumElasticWorkerCount: isFlexConsumption ? null : appServicePlanMaximumElasticWorkerCount ?? 1
    zoneRedundant: zoneRedundant
  }
}

// ================================================= Outputs =================================================
@description('Output the App Service Plan\'s resource id.')
output appServicePlanResourceId string = appServicePlan.id
@description('Output the App Service Plan\'s SKU name.')
output appServicePlanSkuName string = appServicePlan.sku.name
@description('Output the App Service Plan\'s resource name.')
output appServicePlanResourceName string = appServicePlan.name
