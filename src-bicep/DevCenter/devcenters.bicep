/*
.SYNOPSIS
Creating a Dev Center resource.
.DESCRIPTION
This module creates a managed devops pool with the given specs.
.EXAMPLE
<pre>
module devcenter 'br:contosoregistry.azurecr.io/devcenter/devcenters:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'devce')
  params: {
    devcenterName: mydevcenter
  }
}
</pre>
<p>Creates a dev center with the given specs</p>
.LINKS
- [Bicep Microsoft.DevCenter](https://learn.microsoft.com/en-us/azure/templates/microsoft.devcenter/devcenters?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The location of the Dev Center.')
param location string = resourceGroup().location

@description('The name of the Dev Center to upsert.')
@minLength(3)
@maxLength(26)
param devcenterName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@discriminator('type')
type IdentityType =
  | {
    type: 'SystemAssigned'
  }
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).')
param identity IdentityType = {
  type: 'SystemAssigned'
}

// ================================================= Resources =================================================
resource devCenter 'Microsoft.DevCenter/devcenters@2024-07-01-preview' = {
  name: devcenterName
  location: location
  tags: tags
  identity: identity
  properties: {}
}


@description('The resource ID of the Dev Center.')
output devCenterId string = devCenter.id
