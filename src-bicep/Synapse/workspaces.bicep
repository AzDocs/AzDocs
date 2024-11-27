/*
.SYNOPSIS
Create a Synapse Workspace
.DESCRIPTION
Create a Synapse Workspace with the given specs.
.EXAMPLE
<pre>
module synapsews 'br:contosoregistry.azurecr.io/synapse/workspaces:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'synapsews')
  params: {
    synapseWorkSpaceName: 'synapsews'
    sqlAdministratorLogin: 'sqladminuser'
    storageAccountName: 'stgsynws1234'
    azureADOnlyAuthentication: false
    createDevEndpointPe: true
    privateEndpointDevSubnetName: 'privateendpointsubnet'
    privateEndpointVirtualNetworkResourceGroupName: 'sharedservices-rg'
    privateEndpointVirtualNetworkName: 'kpn-shared-dev-001-vnet'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace.</p>
.NOTES
Using a synapse private links hub to connect privately to the workspace Synapse Studio is not supported on the platform, due to DNS limits.
.LINKS
- [Bicep Microsoft.Synapse workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the name of the Synapse Workspace.')
@minLength(1)
@maxLength(50)
param synapseWorkSpaceName string

@maxLength(90)
@description('''
Optional. Workspace managed resource group, when omitted it will be automatically named. The resource group name uniquely identifies the resource group within the user subscriptionId.
The resource group name must be no longer than 90 characters long, and must be alphanumeric characters (Char.IsLetterOrDigit()) and \'-\', \'_\', \'(\', \')\' and\'.\'. 
Note that the name cannot end with \'.\'.
''')
param managedResourceGroupName string = ''

@description('Location for the resource.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object?

@description('Optional. Enable or Disable AzureADOnlyAuthentication on all Workspace sub-resources.')
param azureADOnlyAuthentication bool = false

@description('''
The name of the existing data lake (ADLS Gen2) storage account. 
Your Azure Synapse Analytics workspace uses this storage account as the primary storage account and the container to store workspace data. 
The storage account must be in the same region as the workspace. Users that need to work with the workspace data must have access to this storage account.
Owner and Storage Blob Data Owner roles are required on the storage account.
The Managed identity for your Azure Synapse Analytics workspace needs Storage Blob Data Contributor, it has the same name as the workspace.
''')
param storageAccountName string

@description('The name of the default ADLS Gen2 file system for the data lake storage account. Required and can be any string.')
param defaultDataLakeStorageFilesystem string = 'synapseblob'

@description('''
Optional. Enable this to ensure that connections from your workspace to your data sources use Azure Private Links.
Creating a workspace with a Managed workspace Virtual Network associated with it ensures that your workspace is network isolated from other workspaces.
Data integration and Spark resources are deployed in it. Dedicated SQL pool and serverless SQL pool are multi-tenant capabilities and therefore reside outside of the Managed workspace Virtual Network. Intra-workspace communication to dedicated SQL pool and serverless SQL pool use Azure private links. 
These private links are automatically created for you when you create a workspace with a Managed workspace Virtual Network associated to it.
You can create managed private endpoints to your data sources.
If this is set to false, make sure you add the necessary firewall rules for yourself to allow access to your Synapse workspace for the Dev Portal.
''')
param managedVirtualNetwork bool = true

@description('''
Optional. Create managed private endpoint to the default storage account or not. 
If Yes is selected, a managed private endpoint connection request is sent to the workspace\'s primary Data Lake Storage Gen2 account to access data. 
This must be approved by an owner of the storage account.
''')
param defaultDataLakeStorageCreateManagedPrivateEndpoint bool = false

type customerManagedKeyType = {
  @description('Required. The resource ID of a key vault to reference a customer managed key for encryption from.')
  keyVaultResourceId: string

  @description('Required. The name of the customer managed key to use for encryption.')
  keyName: string

  @description('Optional. The version of the customer managed key to reference for encryption. If not provided, using \'latest\'.')
  keyVersion: string?

  @description('Optional. User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use.')
  userAssignedIdentityResourceId: string?
}
@description('Optional. The customer managed key definition.')
param customerManagedKey customerManagedKeyType?

type managedIdentitiesType = {
  @description('Optional. The resource ID(s) to assign to the resource.')
  userAssignedResourceIds: string[]
}?

@description('Required. Login for administrator access to the workspace\'s SQL pools.')
param sqlAdministratorLogin string = 'sqladminuser'

@description('Optional. Password for administrator access to the workspace\'s SQL pools. If you don\'t provide a password, one will be automatically generated. You can change the password later.')
@secure()
param sqlAdministratorLoginPassword string = ''

// ================================================= Variables =================================================
@description('The format for the data lake URL in the Synapse workspace.')
var datalakeUrlFormat = 'https://{0}.dfs.${environment().suffixes.storage}'

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

@description('Optional. Allowed AAD Tenant IDs For Linking.')
param allowedAadTenantIdsForLinking array = []

@description('Optional. Linked Access Check On Target Resource.')
param linkedAccessCheckOnTargetResource bool = false

@description('Optional. Prevent Data Exfiltration.')
param preventDataExfiltration bool = false

@allowed([
  'Enabled'
  'Disabled'
])
@description('''
Optional. Enable or Disable public network access to workspace.
When public network access is disabled, you can connect to your workspace only using private endpoints. Also any firewall rules that you might configure will not be applied.
And the publish button to the integrated Git repo will not work because the access to Live mode is blocked by the firewall settings.
When public network access is enabled, you can connect to your workspace also from public networks and use firewall rules.
''')
param publicNetworkAccess string = 'Enabled'

@description('Optional. Purview Resource ID.')
param purviewResourceID string = ''

@description('Optional. Git integration settings.')
param workspaceRepositoryConfiguration object?

@description('Optional. Enable or Disable trusted service bypass.')
param trustedServiceBypassEnabled bool = false

@description('The name of the private endpoint for the development endpoint.')
param privateEndpointDevName string = ''
@description('The name of the private endpoint for the Sql OnDemand endpoint.')
param privateEndpointSqlOdName string = ''
@description('The name of the private endpoint for the Sql endpoint.')
param privateEndpointSqlName string = ''

@description('The name of the subnet to deploy the private endpoint for the development endpoint to.')
param privateEndpointDevSubnetName string = ''
@description('The name of the subnet to deploy the private endpoint for the Sql OnDemand endpoint to.')
param privateEndpointSqlOdSubnetName string = ''
@description('The name of the subnet to deploy the private endpoint for the Sql endpoint to.')
param privateEndpointSqlSubnetName string = ''

@description('The name of the resource group where the virtual network resides in.')
param privateEndpointVirtualNetworkResourceGroupName string = ''

@description('The name of the virtual network to deploy the private endpoint for the endpoints to.')
param privateEndpointVirtualNetworkName string = ''

// ================================================= Resources =================================================

resource cMKUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (!empty(customerManagedKey.?userAssignedIdentityResourceId)) {
  name: last(split(customerManagedKey.?userAssignedIdentityResourceId ?? 'dummyMsi', '/'))
  scope: resourceGroup(
    split((customerManagedKey.?userAssignedIdentityResourceId ?? '//'), '/')[2],
    split((customerManagedKey.?userAssignedIdentityResourceId ?? '////'), '/')[4]
  )
}

resource cMKKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId)) {
  name: last(split((customerManagedKey.?keyVaultResourceId ?? 'dummyVault'), '/'))
  scope: resourceGroup(
    split((customerManagedKey.?keyVaultResourceId ?? '//'), '/')[2],
    split((customerManagedKey.?keyVaultResourceId ?? '////'), '/')[4]
  )

  resource cMKKey 'keys@2023-02-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId) && !empty(customerManagedKey.?keyName)) {
    name: customerManagedKey.?keyName ?? 'dummyKey'
  }
}

resource synapseStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkSpaceName
  location: location
  identity: identity
  tags: tags
  properties: {
    azureADOnlyAuthentication: azureADOnlyAuthentication ? azureADOnlyAuthentication : null
    defaultDataLakeStorage: {
      accountUrl: format(datalakeUrlFormat, synapseStorage.name)
      createManagedPrivateEndpoint: managedVirtualNetwork ? defaultDataLakeStorageCreateManagedPrivateEndpoint : null
      filesystem: defaultDataLakeStorageFilesystem
      resourceId: synapseStorage.id
    }
    encryption: !empty(customerManagedKey)
      ? {
          cmk: {
            kekIdentity: !empty(customerManagedKey.?userAssignedIdentityResourceId)
              ? {
                  userAssignedIdentity: cMKUserAssignedIdentity.id
                }
              : {
                  useSystemAssignedIdentity: empty(customerManagedKey.?userAssignedIdentityResourceId)
                }
            key: {
              keyVaultUrl: cMKKeyVault::cMKKey.properties.keyUri
              name: customerManagedKey!.keyName
            }
          }
        }
      : null
    managedResourceGroupName: !empty(managedResourceGroupName) ? managedResourceGroupName : null
    managedVirtualNetwork: managedVirtualNetwork ? 'default' : null
    managedVirtualNetworkSettings: managedVirtualNetwork
      ? {
          allowedAadTenantIdsForLinking: allowedAadTenantIdsForLinking
          linkedAccessCheckOnTargetResource: linkedAccessCheckOnTargetResource
          preventDataExfiltration: preventDataExfiltration
        }
      : null
    publicNetworkAccess: managedVirtualNetwork ? publicNetworkAccess : null
    purviewConfiguration: !empty(purviewResourceID)
      ? {
          purviewResourceId: purviewResourceID
        }
      : null
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: !empty(sqlAdministratorLoginPassword) ? sqlAdministratorLoginPassword : null
    workspaceRepositoryConfiguration: workspaceRepositoryConfiguration
    trustedServiceBypassEnabled: trustedServiceBypassEnabled
  }
}

@description('Workaround for [issue](https://github.com/Azure/bicep/discussions/11212) to select `Allow Azure Synapse Link for Azure SQL Database to bypass firewall rules`.')
resource trustedServiceBypass 'Microsoft.Synapse/workspaces/trustedServiceByPassConfiguration@2021-06-01-preview' = if (trustedServiceBypassEnabled) {
  name: 'default'
  parent: synapseWorkspace
  #disable-next-line BCP187 //supress preview version issue
  properties: {
    trustedServiceBypassEnabled: true
  }
}

module synDevPrivateEndpoint '../Network/privateEndpoints.bicep' = if (!empty(privateEndpointDevName) && !empty(privateEndpointDevSubnetName) && !empty(privateEndpointVirtualNetworkResourceGroupName) && !empty(privateEndpointVirtualNetworkName)) {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'synpedev')
  params: {
    location: location
    privateEndpointGroupId: 'Dev'
    subnetName: privateEndpointDevSubnetName
    targetResourceId: synapseWorkspace.id
    privateEndpointName: privateEndpointDevName
    virtualNetworkResourceGroupName: privateEndpointVirtualNetworkResourceGroupName
    virtualNetworkName: privateEndpointVirtualNetworkName
    createPrivateDnsZone: false //handled by platform
  }
}

module synSqlODPrivateEndpoint '../Network/privateEndpoints.bicep' = if (!empty(privateEndpointSqlOdName) && !empty(privateEndpointSqlOdSubnetName) && !empty(privateEndpointVirtualNetworkResourceGroupName) && !empty(privateEndpointVirtualNetworkName)) {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'synpesqlod')
  params: {
    location: location
    privateEndpointGroupId: 'SqlOnDemand'
    subnetName: privateEndpointSqlOdSubnetName
    targetResourceId: synapseWorkspace.id
    privateEndpointName: privateEndpointSqlOdName
    virtualNetworkResourceGroupName: privateEndpointVirtualNetworkResourceGroupName
    virtualNetworkName: privateEndpointVirtualNetworkName
    createPrivateDnsZone: false //handled by platform
  }
}

module synSqlPrivateEndpoint '../Network/privateEndpoints.bicep' = if (!empty(privateEndpointSqlName) && !empty(privateEndpointSqlSubnetName) && !empty(privateEndpointVirtualNetworkResourceGroupName) && !empty(privateEndpointVirtualNetworkName)) {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'synpesql')
  params: {
    location: location
    privateEndpointGroupId: 'Sql'
    subnetName: privateEndpointSqlSubnetName
    targetResourceId: synapseWorkspace.id
    privateEndpointName: privateEndpointSqlName
    virtualNetworkResourceGroupName: privateEndpointVirtualNetworkResourceGroupName
    virtualNetworkName: privateEndpointVirtualNetworkName
    createPrivateDnsZone: false //handled by platform
  }
}

// ================================================= Outputs =================================================
@description('The name of the deployed Synapse Workspace.')
output synapseWorkSpaceName string = synapseWorkspace.name
@description('The resource ID of the deployed Synapse Workspace.')
output synapseWorkSpaceResourceId string = synapseWorkspace.id
@description('The development endpoint of the deployed Synapse Workspace.')
output developmentEndpoint string = synapseWorkspace.properties.connectivityEndpoints.dev
@description('the web endpoint of the deployed Synapse Workspace.')
output webEndpoint string = synapseWorkspace.properties.connectivityEndpoints.web
@description('The workspace connectivity endpoints.')
output connectivityEndpoints object = synapseWorkspace.properties.connectivityEndpoints
@description('The principal ID of the system assigned identity.')
output systemAssignedManagedIdentityPrincipalId string = synapseWorkspace.?identity.?principalId ?? ''
