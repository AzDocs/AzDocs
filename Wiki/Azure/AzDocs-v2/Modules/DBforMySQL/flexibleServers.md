# flexibleServers

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 

## Synopsis
Deploys an Azure Database for MySQL server and supporting network and firewall configuration.<br>
Use the childresource bicep files to add configurations, like EntraID authentication only, firewall rules, private endpoint connections, etc.

## Description
Creating a Azure Database for MySQL flexible server with the gives specs. <br>
Server names, networking connectivity method, zone redundant HA and backup redundancy cannot be changed after server is created.<br>
In the scenario for using a user-assigned managed identity, ensure that the identity has proper permissions listed in the link below:<br>
[Link](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-azure-ad#grant-permissions-to-user-assigned-managed-identity).

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| mySqlFlexibleServerName | string | <input type="checkbox" checked> | None | <pre></pre> | Server Name for Azure MySQL |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources. |
| mysqlVersion | string | <input type="checkbox"> | `'5.6'` or `'5.7'` or `'8.0'` or `'8.4'` | <pre>'8.4'</pre> | MySQL version |
| skuTier | string | <input type="checkbox"> | `'Burstable'` or `'GeneralPurpose'` or `'MemoryOptimized'` | <pre>'GeneralPurpose'</pre> | Required. The tier of the particular SKU. Tier must align with the "skuName" property. Example, tier cannot be "Burstable" if skuName is "Standard_D4s_v3". |
| skuName | string | <input type="checkbox"> | None | <pre>'Standard_D4ads_v5'</pre> | Azure database for MySQL sku name  |
| mysqlAdminLogin | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | MySQL administrator login name |
| mysqlAdminPassword | string | <input type="checkbox" checked> | Length between 8-* | <pre></pre> | MySQL administrator password |
| publicNetworkAccess | string | <input type="checkbox"> | None | <pre>'Disabled'</pre> | Public network access for the MySQL server. Ignored if "delegatedSubnetResourceId" is provided. |
| delegatedSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional delegated subnet resource id for private network connectivity.<br>Only resources within the virtual network or a peered network to your server will have access. <br>If provided, the server will be associated with this subnet via the API (private connectivity). The subnet must be delegated to 'Microsoft.DBforMySQL/flexibleServers'.<br>Firewall rules and public network access settings will be ignored when this property is provided.<br>Example:<br>delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', '<vnetName>', '<subnetName>') |
| backup | object | <input type="checkbox"> | None | <pre>{<br>  backupRetentionDays: 7<br>  backupIntervalHours: 24<br>  geoRedundantBackup: 'Disabled'<br>}</pre> | Backup configuration for the MySQL server. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Tags to apply to created resources |
| identity | [IdentityType](#IdentityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'None'<br>}</pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. <br>For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).<br>Example:<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>},<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'resourceId('<subscriptionId>', '<resourceGroupName>', 'Microsoft.ManagedIdentity/userAssignedIdentities', '<identityName>')': {}<br>&nbsp;&nbsp;&nbsp;}<br>} |
| storage | object | <input type="checkbox"> | None | <pre>{<br>  storageSizeGB: 20<br>  iops: 360<br>  autoGrow: 'Enabled'<br>}</pre> | Storage configuration for the MySQL server. Storage you provision is the amount of storage capacity available to your server, and is billed by GiB/month.<br>Note that storage cannot be scaled down once the server is created. |
| availabilityZone | int | <input type="checkbox"> | `-1` or `1` or `2` or `3` | <pre>-1</pre> | Required. If set to 1, 2 or 3, the availability zone is hardcoded to that value. <br>If set to -1, no zone is defined. Note that the availability zone numbers here are the logical availability zone in your Azure subscription. <br>Different subscriptions might have a different mapping of the physical zone and logical zone. <br>To understand more, please refer to [Physical and logical availability zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones). |
| highAvailabilityZone | int | <input type="checkbox"> | `-1` or `1` or `2` or `3` | <pre>-1</pre> | Optional. Standby availability zone information of the server. If set to 1, 2 or 3, the availability zone is hardcoded to that value. If set to -1, no zone is defined. Default will have no preference set. |
| highAvailability | string | <input type="checkbox"> | `'Disabled'` or `'SameZone'` or `'ZoneRedundant'` | <pre>'Disabled'</pre> | Optional. The mode for High Availability (HA). It is not supported for the Burstable pricing tier and Zone redundant HA can only be set during server provisioning. |
| maintenanceWindow | object | <input type="checkbox"> | None | <pre>{<br>  batchOfMaintenance: 'Default'<br>  customWindow: 'Enabled'<br>  dayOfWeek: 0<br>  startHour: 0<br>  startMinute: 0<br>}</pre> | Optional. Properties for the maintenence window. If provided, "customWindow" property must exist and set to "Enabled". |
| maintenancePolicy | object | <input type="checkbox"> | None | <pre>{<br>  patchStrategy: 'Regular'<br>}</pre> | Optional. Maintenance policy properties for the MySQL server. |
| mySqlDatabasePort | int | <input type="checkbox"> | None | <pre>3306</pre> | MySQL database port |
| createMode | string | <input type="checkbox"> | `'Default'` or `'GeoRestore'` or `'PointInTimeRestore'` or `'Replica'` | <pre>'Default'</pre> | Optional. The mode to create a new MySQL server. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| mySqlFlexibleServerName | string |  |
| resourceGroupName | string |  |
| resourceId | string |  |

## Examples
<pre>
module mysqlServer 'br:contosoregistry.azurecr.io/dbformysql/flexibleservers:latest' = {
  name: '${deployment().name}-mysql'
  params: {
    serverName: 'my-mysql-server'
    administratorLogin: 'mysqladmin'
    administratorLoginPassword: 'something' // secure param in real usage
  }
}
</pre>
<p>Creates a MySQL flexibleserver with all defaults and no network access.</p>

## Links
- [Bicep Microsoft.DBforMySQL](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbformysql/flexibleservers?pivots=deployment-language-bicep)
