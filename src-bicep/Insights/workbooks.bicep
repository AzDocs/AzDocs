/*
.SYNOPSIS
Creating a Workbook.
.DESCRIPTION
Creating an Azure Monitor Workbook for custom visualization and analysis. Workbooks provide a flexible canvas for data analysis and the creation of rich visual reports within the Azure portal. Only 'shared' kind is currently supported.
<pre>
module workbook 'br:contosoregistry.azurecr.io/insights/workbooks:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'workbook')
  params: {
    name: 'wb-myworkbook-dev'
    displayName: 'My Application Workbook'
    category: 'workbook'
    location: location
    serializedData: loadTextContent('myworkbook.json')
    sourceId: resourceId('Microsoft.Insights/components', 'myAppInsights')
    version: 'Notebook/1.0'
  }
}
</pre>
<p>Creates an Azure Monitor Workbook with custom visualization and analysis capabilities. The workbook is deployed to a resource group and requires a category, displayName, and serializedData containing valid JSON configuration.</p>
.LINKS
- [Bicep Workbooks](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/workbooks?pivots=deployment-language-bicep)
*/
//--------------------------------------------------------------------------------
// Parameters
//--------------------------------------------------------------------------------
@description('Workbook category, as defined by the user at creation time.')
@minLength(1)
param category string

@description('The user-defined name (display name) of the workbook.')
@minLength(1)
param displayName string

@description('Identity used for BYOS (Bring Your Own Storage).')
param identity object?

@description('Optional workbook kind. Only "shared" is supported currently.')
@allowed(['shared'])
param kind string = 'shared'

@description('The geo-location where the resource lives.')
param location string

@description('The resource name.')
@minLength(1)
@maxLength(260)
param name string

@description('Configuration of this particular workbook. Configuration data is a string containing valid JSON.')
@minLength(1)
param serializedData string

@description('ResourceId for a source resource.')
param sourceId string?

@description('The resourceId to the storage account when bring your own storage is used.')
param storageUri string?

@description('''
The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Workbook schema version format, like ```Notebook/1.0``` which should match the workbook in serializedData.')
param version string?

@description('The description of the workbook.')
param workbookDescription string?

//--------------------------------------------------------------------------------
// Resources
//--------------------------------------------------------------------------------
resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  identity: identity
  kind: kind
  location: location
  name: name
  properties: union(
    {
      category: category
      displayName: displayName
      serializedData: serializedData
    },
    !empty(workbookDescription) ? { description: workbookDescription } : {},
    !empty(sourceId) ? { sourceId: sourceId } : {},
    !empty(storageUri) ? { storageUri: storageUri } : {},
    !empty(version) ? { version: version } : {}
  )
  tags: tags
}

//--------------------------------------------------------------------------------
// Outputs
//--------------------------------------------------------------------------------
@description('The resource ID of the workbook.')
output workbookId string = workbook.id

@description('The name of the workbook.')
output workbookName string = workbook.name
