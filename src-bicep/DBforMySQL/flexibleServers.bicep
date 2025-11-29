/*
.SYNOPSIS
Deploys an Azure Database for MySQL server and supporting network and firewall configuration.
.DESCRIPTION
Creating a Azure Database for MySQL flexible server with the gives specs. 
Server names, networking connectivity method, zone redundant HA and backup redundancy cannot be changed after server is created.
In the scenario for using a user-assigned managed identity, ensure that the identity has proper permissions listed in the link below:
[Link](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-azure-ad#grant-permissions-to-user-assigned-managed-identity).
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.DBforMySQL](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbformysql/flexibleservers?pivots=deployment-language-bicep)
*/
@description('Server Name for Azure MySQL')
param mySqlFlexibleServerName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('MySQL version')
@allowed([
  '5.6'
  '5.7'
  '8.0'
  '8.4'
])
param mysqlVersion string = '8.4'

@description('Required. The tier of the particular SKU. Tier must align with the "skuName" property. Example, tier cannot be "Burstable" if skuName is "Standard_D4s_v3".')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Azure database for MySQL sku name ')
param skuName string = 'Standard_D4ads_v5'

@description('MySQL administrator login name')
@minLength(1)
param mysqlAdminLogin string

@description('MySQL administrator password')
@minLength(8)
@secure()
param mysqlAdminPassword string

@description('Public network access for the MySQL server. Ignored if "delegatedSubnetResourceId" is provided.')
param publicNetworkAccess string = 'Disabled'

@description('''
Optional delegated subnet resource id for private network connectivity (e.g. /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/.../subnets/...). 
If provided, the server will be associated with this subnet via the API (private connectivity). The subnet must be delegated to 'Microsoft.DBforMySQL/flexibleServers'.
Example:
delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', '<vnetName>', '<subnetName>')
''')
param delegatedSubnetResourceId string = ''

@description('Backup configuration for the MySQL server.')
param backup object = {
  backupRetentionDays: 7
  backupIntervalHours: 24
  geoRedundantBackup: 'Disabled'
}

@description('Tags to apply to created resources')
param tags object = {}

@discriminator('type')
type IdentityType =
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('''
Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. 
For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).
Example:
identity: {
  type: 'None'
},
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    'resourceId('<subscriptionId>', '<resourceGroupName>', 'Microsoft.ManagedIdentity/userAssignedIdentities', '<identityName>')': {}
  }
}
''')
param identity IdentityType = {
  type: 'None'
}

@description('''
Storage configuration for the MySQL server. Storage you provision is the amount of storage capacity available to your server, and is billed by GiB/month.
Note that storage cannot be scaled down once the server is created.
''')
param storage object = {
  storageSizeGB: 20
  iops: 360
  autoGrow: 'Enabled'
}

@allowed([
  -1
  1
  2
  3
])
@description('''
Required. If set to 1, 2 or 3, the availability zone is hardcoded to that value. 
If set to -1, no zone is defined. Note that the availability zone numbers here are the logical availability zone in your Azure subscription. 
Different subscriptions might have a different mapping of the physical zone and logical zone. 
To understand more, please refer to [Physical and logical availability zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones).
''')
param availabilityZone int = -1

@description('Optional. Standby availability zone information of the server. If set to 1, 2 or 3, the availability zone is hardcoded to that value. If set to -1, no zone is defined. Default will have no preference set.')
@allowed([
  -1
  1
  2
  3
])
param highAvailabilityZone int = -1

@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
@description('Optional. The mode for High Availability (HA). It is not supported for the Burstable pricing tier and Zone redundant HA can only be set during server provisioning.')
param highAvailability string = 'Disabled'

@description('Optional. Properties for the maintenence window. If provided, "customWindow" property must exist and set to "Enabled".')
param maintenanceWindow object = {
  batchOfMaintenance: 'Default'
  customWindow: 'Enabled'
  dayOfWeek: 0
  startHour: 0
  startMinute: 0
}

@description('Optional. Maintenance policy properties for the MySQL server.')
param maintenancePolicy object = {
  patchStrategy: 'Regular'
}

@description('MySQL database port')
param mySqlDatabasePort int = 3306

@description('Compute and storage redundancy options for the MySQL server.')
var standByAvailabilityZone = {
  Disabled: -1
  SameZone: availabilityZone
  ZoneRedundant: highAvailabilityZone
}[?highAvailability]

//------------------------------------------------------------------------------------
// Resources
//------------------------------------------------------------------------------------

resource mySqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2024-12-30' = {
  name: mySqlFlexibleServerName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  identity: identity
  tags: tags
  properties: {
    administratorLogin: mysqlAdminLogin
    administratorLoginPassword: mysqlAdminPassword
    version: mysqlVersion
    network: {
      publicNetworkAccess: publicNetworkAccess
      delegatedSubnetResourceId: (empty(delegatedSubnetResourceId) ? null : delegatedSubnetResourceId)
    }
    storage: storage
    backup: backup
    availabilityZone: availabilityZone != -1 ? string(availabilityZone) : ''
    highAvailability: {
      mode: highAvailability
      standbyAvailabilityZone: standByAvailabilityZone != -1 ? string(standByAvailabilityZone) : ''
    }
    maintenanceWindow: !empty(maintenanceWindow)
      ? {
          customWindow: maintenanceWindow.customWindow
          dayOfWeek: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.dayOfWeek : 0
          startHour: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.startHour : 0
          startMinute: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.startMinute : 0
        }
      : null
    maintenancePolicy: maintenancePolicy
    databasePort: mySqlDatabasePort
  }
}

output mySqlFlexibleServerName string = mySqlFlexibleServer.name
output resourceGroupName string = resourceGroup().name
output resourceId string = mySqlFlexibleServer.id
