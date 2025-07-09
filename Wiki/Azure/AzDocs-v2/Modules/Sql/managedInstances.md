# managedInstances

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="managedInstanceExternalAdministratorType">managedInstanceExternalAdministratorType</a>  | <pre>{</pre> |  | The Azure Active Directory administrator type for SQL Managed Instance. | 
| <a id="skuFamily">skuFamily</a>  | <pre>'Gen5' &#124; 'G8IM' &#124; 'G8IH'</pre> |  | The SKU family for the SQL Managed Instance. This defines the generation and type of hardware used. | 
| <a id="skuName">skuName</a>  | <pre>'GP_Gen5' &#124; 'GP_G8IM' &#124; 'GP_G8IH' &#124; 'BC_Gen5' &#124; 'BC_G8IM' &#124; 'BC_G8IH'</pre> |  | The SKU for the SQL Managed Instance. This defines the performance and capacity characteristics of the instance. | 
| <a id="skuTier">skuTier</a>  | <pre>'GeneralPurpose' &#124; 'BusinessCritical'</pre> |  | The SKU tier for the SQL Managed Instance. This defines the type of workload the instance is optimized for. | 
| <a id="servicePrincipalType">servicePrincipalType</a>  | <pre>{</pre> |  | The service principal type for SQL Managed Instance. | 
| <a id="skuType">skuType</a>  | <pre>{</pre> |  | SQL Managed Instance SKU configuration. | 

## Synopsis
Creating a SQL Managed Instance

## Description
Creating a SQL Managed Instance with the given specifications.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| administratorLogin | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The username for the SQL Managed Instance administrator login. |
| administratorLoginPassword | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Password for the SQL Managed Instance administrator login |
| administrators | managedInstanceExternalAdministratorType? | <input type="checkbox" checked> | None | <pre></pre> | The Azure Active Directory administrator of the SQL Managed Instance. This can only be used at instance create time. |
| authenticationMetadata | string? | <input type="checkbox" checked> | None | <pre></pre> | The managed instance\'s authentication metadata lookup mode. |
| collation | string | <input type="checkbox" checked> | `'Arabic_100_CI_AS'` or `'Chinese_PRC_CI_AS'` or `'Cyrillic_General_100_CI_AS'` or `'Finnish_Swedish_100_CI_AS'` or `'Japanese_CI_AS'` or `'Latin1_General_100_CI_AS'` or `'Latin1_General_100_CS_AS'` or `'SQL_Latin1_General_CP1_CI_AS'` or `'Latin1_General_BIN'` or `'Latin1_General_CI_AS'` or `'Latin1_General_CS_AS'` | <pre></pre> | Collation of the managed instance. |
| databaseFormat | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the internal format of instance databases specific to the SQL engine version. |
| dnsZonePartner | string? | <input type="checkbox" checked> | None | <pre></pre> | The resource id of another managed instance whose DNS zone this managed instance will share after creation. |
| hybridSecondaryUsage | string? | <input type="checkbox" checked> | None | <pre></pre> | Hybrid secondary usage. Possible values are \'Active\' (default value) and \'Passive\' (customer uses the secondary as Passive DR). |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| instancePoolId | string? | <input type="checkbox" checked> | None | <pre></pre> | The Id of the instance pool this managed server belongs to. Id must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/instancePools/{instancePoolName} |
| isGeneralPurposeV2 | bool? | <input type="checkbox" checked> | None | <pre></pre> | Whether or not this is a GPv2 variant of General Purpose edition. |
| keyId | string? | <input type="checkbox" checked> | None | <pre></pre> | A CMK URI of the key to use for encryption. |
| licenseType | string? | <input type="checkbox" checked> | None | <pre></pre> | The license type. Possible values are \'LicenseIncluded\' (regular price inclusive of a new SQL license) and \'BasePrice\' (discounted AHB price for bringing your own SQL licenses). |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. |
| maintenanceConfigurationId | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies maintenance configuration id to apply to this managed instance. Id must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/maintenanceConfigurations/{maintenanceConfigurationName} |
| managedInstanceCreateMode | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the mode of database creation. Default: Regular instance creation. Restore: Creates an instance by restoring a set of backups to specific point in time. RestorePointInTime and SourceManagedInstanceId must be specified. |
| minimalTlsVersion | string | <input type="checkbox"> | `'1.2'` | <pre>'1.2'</pre> | Minimal TLS version. Allowed values: \'1.2\' |
| pricingModel | string? | <input type="checkbox" checked> | None | <pre></pre> | Pricing model of Managed Instance. |
| primaryUserAssignedIdentityId | string? | <input type="checkbox" checked> | None | <pre></pre> | The resource id of a user assigned identity to be used by default. Must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{userAssignedIdentityName} |
| proxyOverride | string? | <input type="checkbox" checked> | None | <pre></pre> | Connection type used for connecting to the instance. |
| publicDataEndpointEnabled | bool? | <input type="checkbox" checked> | None | <pre></pre> | Whether or not the public data endpoint is enabled. |
| requestedBackupStorageRedundancy | string? | <input type="checkbox" checked> | None | <pre></pre> | The storage account type to be used to store backups for this instance. The options are Local (LocallyRedundantStorage), Zone (ZoneRedundantStorage), Geo (GeoRedundantStorage) and GeoZone(GeoZoneRedundantStorage) |
| restorePointInTime | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. |
| servicePrincipal | servicePrincipalType? | <input type="checkbox" checked> | None | <pre></pre> | The managed instance\'s service principal. |
| sku | skuType | <input type="checkbox" checked> | None | <pre></pre> | Managed instance SKU. Allowed values for sku.name: `GP_Gen5, GP_G8IM, GP_G8IH, BC_Gen5, BC_G8IM, BC_G8IH` |
| sqlManagedInstanceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Name of the SQL Managed Instance resource |
| sourceManagedInstanceId | string? | <input type="checkbox" checked> | None | <pre></pre> | The resource identifier of the source managed instance to restore from when using PointInTimeRestore mode.<br>This parameter is required when managedInstanceCreateMode is set to 'PointInTimeRestore'.<br>Must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/managedInstances/{managedInstanceName}<br><br>For cross-instance restores, both source and target instances must be in the same region.<br>For cross-subscription restores, both subscriptions must be in the same tenant. |
| storageIOps | int? | <input type="checkbox" checked> | Value between 300-80000 | <pre></pre> | Storage IOps. Minimum value: 300. Maximum value: 80000. Increments of 1 IOps allowed only. Maximum value depends on the selected hardware family and number of vCores. |
| storageSizeInGB | int | <input type="checkbox"> | Value between 32-16384 | <pre>32</pre> | Storage size in GB. Minimum value: 32. Maximum value: 16384. Increments of 32 GB allowed only. Maximum value depends on the selected hardware family and number of vCores. |
| storageThroughputMBps | int? | <input type="checkbox" checked> | None | <pre></pre> | Storage throughput MBps parameter is not supported in the instance create/update operation. |
| subnetId | string? | <input type="checkbox" checked> | None | <pre></pre> | Subnet resource ID for the managed instance. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| timezoneId | string? | <input type="checkbox" checked> | None | <pre></pre> |  |
| totalMemoryMB | int? | <input type="checkbox" checked> | Value between 7168-891328 | <pre></pre> | Total memory in MB. Minimum value: 7168. Maximum value: 891328. Increments of 1 MB allowed only. Maximum value depends on the selected hardware family and number of vCores. |
| zoneRedundant | bool? | <input type="checkbox" checked> | None | <pre></pre> | Whether or not the multi-az is enabled. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| id | string | The resource ID of the SQL Managed Instance. |
| name | string | The name of the SQL Managed Instance. |

## Examples
<pre>
module sqlManagedInstance 'br:contosoregistry.azurecr.io/sql/managedInstances.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlmi')
  params: {
    sqlManagedInstanceName: sqlMiName
    location: location
    tags: tags
    administratorLogin: 'miadmin'
    administratorLoginPassword: sqlMiPassword
    subnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/vnet-sqlmi/subnets/sqlmi-subnet'
    sku: {
      name: 'GP_Gen5'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: 8
    }
    storageSizeInGB: 256
    licenseType: 'LicenseIncluded'
    minimalTlsVersion: '1.2'
  }
}
</pre>
<p>Creates a SQL Managed Instance with General Purpose tier</p>
<pre>
module sqlManagedInstance 'br:contosoregistry.azurecr.io/sql/managedInstances.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'sqlmi')
  params: {
    sqlManagedInstanceName: sqlMiName
    location: location
    tags: tags
    administratorLogin: 'miadmin'
    administratorLoginPassword: sqlMiPassword
    subnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/vnet-sqlmi/subnets/sqlmi-subnet'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'admin@contoso.com'
      principalType: 'User'
      sid: 'a348f815-0d14-4a85-b2fe-d3b36519e4fg'
      tenantId: subscription().tenantId
    }
    sku: {
      name: 'BC_Gen5'
      tier: 'BusinessCritical'
      family: 'Gen5'
      capacity: 16
    }
    storageSizeInGB: 512
    licenseType: 'BasePrice'
    zoneRedundant: true
  }
}
</pre>
<p>Creates a SQL Managed Instance with Business Critical tier and Entra ID authentication only.</p>

## Links
- [Bicep Microsoft.SQL managedInstances](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/managedinstances?pivots=deployment-language-bicep)<br>
- [Azure SQL Managed Instance Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview)<br>
- [SQL Managed Instance SKUs](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/resource-limits)
