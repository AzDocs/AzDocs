// Parameters
@description('Specifies the name of the Log Analytics workspace. This LAW should be pre-existing.')
@minLength(4)
@maxLength(63)
param logAnalyticsWorkspaceName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Who is authoring this solution type. Can be either `Microsoft` or `ThirdParty`.')
@allowed([
  'Microsoft'
  'ThirdParty'
])
param AuthoredBy string = 'Microsoft'

// Variables
@description('''
The solution type to upsert. NOTE: This is case-sensitive.

Most used options are:
SecurityCenterFree, Security, Updates, ContainerInsights, ServiceMap, AzureActivity, ChangeTracking, VMInsights, SecurityInsights, NetworkMonitoring, SQLVulnerabilityAssessment, SQLAdvancedThreatProtection, AntiMalware, AzureAutomation, LogicAppsManagement, SQLDataClassification.
''')
param solutionProduct string

@description('Allows you to override the publisher for the plan.')
param Publisher string = 'Microsoft'

@description('Determine the opening bracket for this solution. For options, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.operationsmanagement/solutions?pivots=deployment-language-bicep#solutions.')
var openBracket = AuthoredBy == 'Microsoft' ? '(' : '['
@description('Determine the closing bracket for this solution. For options, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.operationsmanagement/solutions?pivots=deployment-language-bicep#solutions.')
var closeBracket = AuthoredBy == 'Microsoft' ? ')' : ']'
@description('Determine the full solution name.')
var solutionName = '${solutionProduct}${openBracket}${logAnalyticsWorkspaceName}${closeBracket}'

@description('Fetch the existing log analytics workspace.')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

@description('Upsert the Log Analytics Workspace Solution.')
resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: solutionName
  location: location
  tags: tags
  plan: {
    name: solutionName
    promotionCode: ''
    product: AuthoredBy == 'Microsoft' ? 'OMSGallery/${solutionProduct}' : solutionProduct
    publisher: Publisher
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}
