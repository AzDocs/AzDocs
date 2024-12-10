/*
.SYNOPSIS
Create or add an group in Api Management Service.
.DESCRIPTION
Create an internal group or add an existing external group in Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/groups.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'groups')
  params: {
    apiManagementServiceName: apiManagementServiceName
    groupName: groupName
    groupDescription: groupDescription
    groupExternalId: groupExternalId
    groupType: groupType
  }
}
</pre>
<p>Create an internal group or add an existing external group in Api Management Service.</p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/groups?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('''
Character limit: 1-50

Valid characters:
Alphanumerics and hyphens.

Start with letter and end with alphanumeric.

Resource name must be unique across Azure.
''')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('Group description.')
param groupDescription string?

@description('Group name.')
@minLength(1)
param groupName string

@description('''
Identifier of the external groups, this property contains the id of the group from the external identity provider, e.g. 
for Azure Active Directory: 

`aad://<tenant>.onmicrosoft.com/groups/<group object id>` 

otherwise the value is null.
''')
@minLength(1)
param groupExternalId string?

@description('Group type.')
@allowed([
  'custom'
  'external'
  'system'
])
param groupType string = 'custom'

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource group 'Microsoft.ApiManagement/service/groups@2023-03-01-preview' = {
  parent: apiManagementService
  name: groupName
  properties: {
    description: groupDescription
    displayName: groupName
    externalId: groupExternalId
    type: groupType
  }
}

@description('The id of the group.')
output groupId string = group.id
@description('The name of the group.')
output groupName string = group.name
