/*
.SYNOPSIS
Creating a SQL Managed Instance
.DESCRIPTION
Creating a SQL Managed Instance with the given specifications.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.SQL managedInstances](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/managedinstances?pivots=deployment-language-bicep)
- [Azure SQL Managed Instance Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview)
- [SQL Managed Instance SKUs](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/resource-limits)
*/

// ================================================= Parameters =================================================
@description('The username for the SQL Managed Instance administrator login.')
@minLength(1)
param administratorLogin string

@secure()
@minLength(1)
@description('Password for the SQL Managed Instance administrator login')
param administratorLoginPassword string

@description('The Azure Active Directory administrator of the SQL Managed Instance. This can only be used at instance create time.')
param administrators managedInstanceExternalAdministratorType?

@description('The managed instance\'s authentication metadata lookup mode.')
@allowed(['AzureAD', 'Paired', 'Windows'])
param authenticationMetadata string?

@description('Collation of the managed instance.')
@allowed([
  'Arabic_100_CI_AS'
  'Chinese_PRC_CI_AS'
  'Cyrillic_General_100_CI_AS'
  'Finnish_Swedish_100_CI_AS'
  'Japanese_CI_AS'
  'Latin1_General_100_CI_AS'
  'Latin1_General_100_CS_AS'
  'SQL_Latin1_General_CP1_CI_AS'
  'Latin1_General_BIN'
  'Latin1_General_CI_AS'
  'Latin1_General_CS_AS'
])
param collation string

@description('Specifies the internal format of instance databases specific to the SQL engine version.')
@allowed(['AlwaysUpToDate', 'SQLServer2022'])
param databaseFormat string?

@description('The resource id of another managed instance whose DNS zone this managed instance will share after creation.')
param dnsZonePartner string?

@description('Hybrid secondary usage. Possible values are \'Active\' (default value) and \'Passive\' (customer uses the secondary as Passive DR).')
@allowed(['Active', 'Passive'])
param hybridSecondaryUsage string?

@description('Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).')
param identity object = {
  type: 'SystemAssigned'
}

@description('The Id of the instance pool this managed server belongs to. Id must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/instancePools/{instancePoolName}')
param instancePoolId string?

@description('Whether or not this is a GPv2 variant of General Purpose edition.')
param isGeneralPurposeV2 bool?

@description('A CMK URI of the key to use for encryption.')
param keyId string?

@description('The license type. Possible values are \'LicenseIncluded\' (regular price inclusive of a new SQL license) and \'BasePrice\' (discounted AHB price for bringing your own SQL licenses).')
@allowed(['BasePrice', 'LicenseIncluded'])
param licenseType string?

@description('Specifies the Azure location where the resource should be created.')
param location string = resourceGroup().location

@description('Specifies maintenance configuration id to apply to this managed instance. Id must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/maintenanceConfigurations/{maintenanceConfigurationName}')
param maintenanceConfigurationId string?

@description('Specifies the mode of database creation. Default: Regular instance creation. Restore: Creates an instance by restoring a set of backups to specific point in time. RestorePointInTime and SourceManagedInstanceId must be specified.')
@allowed(['Default', 'PointInTimeRestore'])
param managedInstanceCreateMode string?

@description('Minimal TLS version. Allowed values: \'1.2\'')
@allowed([
  '1.2'
])
param minimalTlsVersion string = '1.2'

@description('Pricing model of Managed Instance.')
@allowed(['Freemium', 'Regular'])
param pricingModel string?

@description('The resource id of a user assigned identity to be used by default. Must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{userAssignedIdentityName}')
param primaryUserAssignedIdentityId string?

@description('Connection type used for connecting to the instance.')
@allowed(['Default', 'Proxy', 'Redirect'])
param proxyOverride string?

@description('Whether or not the public data endpoint is enabled.')
param publicDataEndpointEnabled bool?

@description('The storage account type to be used to store backups for this instance. The options are Local (LocallyRedundantStorage), Zone (ZoneRedundantStorage), Geo (GeoRedundantStorage) and GeoZone(GeoZoneRedundantStorage)')
@allowed(['Geo', 'GeoZone', 'Local', 'Zone'])
param requestedBackupStorageRedundancy string?

@description('Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database.')
param restorePointInTime string?

@description('The managed instance\'s service principal.')
param servicePrincipal servicePrincipalType?

@description('Managed instance SKU. Allowed values for sku.name: `GP_Gen5, GP_G8IM, GP_G8IH, BC_Gen5, BC_G8IM, BC_G8IH`')
param sku skuType

@minLength(1)
@description('Name of the SQL Managed Instance resource')
param sqlManagedInstanceName string

@description('''
The resource identifier of the source managed instance to restore from when using PointInTimeRestore mode.
This parameter is required when managedInstanceCreateMode is set to 'PointInTimeRestore'.
Must be in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Sql/managedInstances/{managedInstanceName}

For cross-instance restores, both source and target instances must be in the same region.
For cross-subscription restores, both subscriptions must be in the same tenant.
''')
param sourceManagedInstanceId string?

@description('''Storage IOps for SQL Managed Instance. Valid ranges depend on SKU, tier, and vCore count:

General Purpose tier (GP_Gen5, GP_G8IM, GP_G8IH):
- Minimum: 1536 IOps for all vCore counts
- Maximum: Scales with vCores (6400 for 4 vCores, 12800 for 8 vCores, 25600 for 16 vCores, 38400 for 24 vCores, 51200 for 32 vCores, 64000 for 40 vCores, 80000 for 64+ vCores)
- Recommended: 30-40% of maximum (3000 for 8 vCores, 5000 for 16 vCores, etc.)

Business Critical tier (BC_Gen5, BC_G8IM, BC_G8IH):
- Minimum: 1536 IOps for all vCore counts
- Maximum: 4000 IOps per vCore (16000 for 4 vCores, 32000 for 8 vCores, 64000 for 16 vCores, etc.)
- Recommended: 50% of maximum (8000 for 4 vCores, 16000 for 8 vCores, etc.)

Note: While the type definition allows 300-80000 IOps for flexibility, Azure enforces the limits above at deployment time.
''')
@minValue(300)
@maxValue(80000)
param storageIOps int?

@description('Storage size in GB. Minimum value: 32. Maximum value: 16384. Increments of 32 GB allowed only. Maximum value depends on the selected hardware family and number of vCores.')
@minValue(32)
@maxValue(16384)
param storageSizeInGB int = 32

@description('Storage throughput MBps parameter is not supported in the instance create/update operation.')
param storageThroughputMBps int?

@description('Subnet resource ID for the managed instance.')
param subnetId string?

@description('''
The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''Id of the timezone. Allowed values are timezones supported by Windows.

A list of available timezones can be found [here](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/sql-managed-instance-timezones).''')
param timezoneId string?

@description('Total memory in MB. Minimum value: 7168. Maximum value: 891328. Increments of 1 MB allowed only. Maximum value depends on the selected hardware family and number of vCores.')
@minValue(7168)
@maxValue(891328)
param totalMemoryMB int?

@description('Whether or not the multi-az is enabled.')
param zoneRedundant bool?

// ================================================= Custom Types =================================================
@description('The Azure Active Directory administrator type for SQL Managed Instance.')
type managedInstanceExternalAdministratorType = {
  @description('Type of the server administrator. Must be `ActiveDirectory`.')
  administratorType: 'ActiveDirectory'

  @description('Azure Active Directory only Authentication enabled.')
  azureADOnlyAuthentication: bool

  @description('Login name of the server administrator.')
  login: string

  @description('Principal Type of the server administrator.')
  principalType: 'Application' | 'Group' | 'User'

  @description('SID (object ID) of the server administrator.')
  @minLength(36)
  @maxLength(36)
  sid: string

  @description('Tenant ID of the administrator.')
  @minLength(36)
  @maxLength(36)
  tenantId: string
}

@description('The SKU family for the SQL Managed Instance. This defines the generation and type of hardware used.')
type skuFamily = 'Gen5' | 'G8IM' | 'G8IH'

@description('The SKU for the SQL Managed Instance. This defines the performance and capacity characteristics of the instance.')
type skuName = 'GP_Gen5' | 'GP_G8IM' | 'GP_G8IH' | 'BC_Gen5' | 'BC_G8IM' | 'BC_G8IH'

@description('The SKU tier for the SQL Managed Instance. This defines the type of workload the instance is optimized for.')
type skuTier = 'GeneralPurpose' | 'BusinessCritical'

@description('The service principal type for SQL Managed Instance.')
type servicePrincipalType = {
  @description('Service principal type.')
  type: 'None' | 'SystemAssigned'
}

@description('SQL Managed Instance SKU configuration.')
type skuType = {
  @minValue(1)
  @description('''
Number of vCores for the SQL Managed Instance. This is the primary property to set the compute capacity of the instance.

For `Gen5`, valid values are typically `4, 8, 16, 24, or 32` vCores.

For G8IM and G8IH, the range and increments may differ.

Allowed values for General Purpose: 8, 16, 24, 32, 40, 64, 80
Allowed values for Business Critical: 8, 16, 24, 32, 40, 64, 80''')
  capacity: int

  @description('If the service has different generations of hardware, for the same SKU, then that can be captured here. `Optional`')
  family: skuFamily?

  @description('The SKU family for the SQL Managed Instance. This defines the generation and type of hardware used. `Mandatory`')
  name: skuName

  @description('Size of the particular SKU. `Optional`')
  size: string?

  @description('The SKU tier for the SQL Managed Instance. This defines the type of workload the instance is optimized for. `Optional`')
  tier: skuTier
}

// ================================================= Resources =================================================
resource sqlManagedInstance 'Microsoft.Sql/managedInstances@2024-05-01-preview' = {
  identity: identity
  location: location
  name: sqlManagedInstanceName
  properties: {
    // Required properties for managed instance creation
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword

    // Azure AD administrator configuration - only used at creation time
    administrators: administrators

    // Authentication configuration
    authenticationMetadata: authenticationMetadata

    // Database configuration
    collation: collation
    databaseFormat: databaseFormat
    minimalTlsVersion: minimalTlsVersion

    // Networking configuration
    dnsZonePartner: dnsZonePartner
    proxyOverride: proxyOverride
    publicDataEndpointEnabled: publicDataEndpointEnabled
    subnetId: subnetId

    // Instance configuration
    hybridSecondaryUsage: hybridSecondaryUsage
    instancePoolId: instancePoolId
    isGeneralPurposeV2: isGeneralPurposeV2
    licenseType: licenseType
    managedInstanceCreateMode: managedInstanceCreateMode
    pricingModel: pricingModel

    // Storage configuration
    storageIOps: storageIOps
    storageSizeInGB: storageSizeInGB
    storageThroughputMBps: storageThroughputMBps

    // Security configuration
    keyId: keyId
    servicePrincipal: servicePrincipal

    // Backup configuration
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy

    // Identity configuration
    primaryUserAssignedIdentityId: primaryUserAssignedIdentityId

    // Performance configuration
    totalMemoryMB: totalMemoryMB

    // High availability configuration
    zoneRedundant: zoneRedundant

    // Maintenance configuration
    maintenanceConfigurationId: maintenanceConfigurationId
    timezoneId: timezoneId

    // Restore configuration - only used when managedInstanceCreateMode is 'PointInTimeRestore'
    restorePointInTime: managedInstanceCreateMode == 'PointInTimeRestore' ? restorePointInTime : null
    sourceManagedInstanceId: managedInstanceCreateMode == 'PointInTimeRestore' ? sourceManagedInstanceId : null
  }
  sku: sku
  tags: tags
}

// ================================================= Outputs =================================================
@description('The resource ID of the SQL Managed Instance.')
output id string = sqlManagedInstance.id

@description('The name of the SQL Managed Instance.')
output name string = sqlManagedInstance.name
