/*
.SYNOPSIS
Adds or updates a configuration setting on an existing Azure Database for MySQL Flexible Server.
Can be found in the Server parameters section of the settings in the Azure portal for MySQL flexible servers.
.DESCRIPTION
This file declares the `configurations` child resource for a MySQL flexible server. Use this
module to create or update a server-level configuration (name/value) on an existing flexible server.
The target server must already exist; this module targets the `configurations` child resource.
.PARAMETER mySqlFlexibleServerName
Name of the existing MySQL flexible server to which the configuration will be applied.
.EXAMPLE
<pre>
module mysqlConfig 'br:contosoregistry.azurecr.io/dbformysql/flexibleservers/configurations:latest' = {
  name: '${deployment().name}-mysql-config'
  params: {
    mySqlFlexibleServerName: 'my-mysql-server'
    mySqlConfigurationValue: 'ON'
    mySqlConfigurationName: 'aad_auth_only'
  }
}
</pre>
<p>Sets the 'Microsoft Entra authentication only' configuration to 'ON' on the specified MySQL flexible server.</p>
.LINKS
- https://learn.microsoft.com/azure/mysql/flexible-server/
.NOTES
- Supported configuration names and values depend on the MySQL server version and SKU.
*/
@description('Server Name for the existing Azure MySQL flexible server to which the configuration will be applied.')
param mySqlFlexibleServerName string

@description('''
The name of the MySQL configuration to set. For example, "aad_auth_only" or "activate_all_roles_on_login". 
The list of allowed name values can be fetched on an existing MySQL server with: `az rest --method get --uri "https://management.azure.com/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>/providers/Microsoft.DBforMySQL/flexibleServers/<serverName>/configurations?api-version=2024-12-30" 
''')
param mySqlConfigurationName string = 'aad_auth_only'

@description('Optional. Source of the configuration value. Possible values include: "system-default", "user-override".')
@allowed([
  'system-default'
  'user-override'
])
param mySqlConfigurationSource string?

@description('The value to set for the MySQL configuration.')
param mySqlConfigurationValue string

@description('Optional.The current value of the MySQL configuration.')
param mySqlCurrentValue string?


resource mySqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2024-12-30' existing = {
  name: mySqlFlexibleServerName
}

resource mySqlConfiguration 'Microsoft.DBforMySQL/flexibleServers/configurations@2024-12-30' = {
  parent: mySqlFlexibleServer
  name: mySqlConfigurationName
  properties: {
    currentValue: mySqlCurrentValue ?? ''
    source: mySqlConfigurationSource ?? ''
    value: mySqlConfigurationValue
  }
}
