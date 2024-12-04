/*
.SYNOPSIS
Creating a Dev Center project.
.DESCRIPTION
This module creates a Dev Center project in an existing Dev Center.
.EXAMPLE
<pre>
module devcenterproject 'br:contosoregistry.azurecr.io/devcenter/projects:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'devpr')
  params: {
    devcenterName: mydevcenter
    devCenterProjectName: mydevcenterproject
  }
}
</pre>
<p>Creates a dev center project with the given specs</p>
.LINKS
- [Bicep Microsoft.Devcenter Projects](https://learn.microsoft.com/en-us/azure/templates/microsoft.devcenter/projects?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The location of the Dev Center project.')
param location string = resourceGroup().location

@description('The name of the existing Dev Center.')
param devCenterName string

@description('The name of the Dev Center project.')
@minLength(3)
param devCenterProjectName string

@description('The description of the Dev Center project.')
param devCenterProjectDescription string = 'Dev Center project'

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

@description('Managed service identity to use for this resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).')
param identity IdentityType = {
  type: 'SystemAssigned'
}

@description('When provided, allows to restrict how many dev boxes each developer can create in a project.')
param maxDevBoxesPerUser int?

// ================================================= Resources =================================================
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

resource devCenterProject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: devCenterProjectName
  location: location
  identity: identity
  properties: {
    description: devCenterProjectDescription
    devCenterId: devCenter.id
    maxDevBoxesPerUser: maxDevBoxesPerUser ?? null
  }
}

@description('The resource ID of the project created in the Dev Center.')
output devCenterProjectResourceId string = devCenterProject.id

@description('The name of the project created in the Dev Center.')
output devCenterProjectName string = devCenterProject.name
