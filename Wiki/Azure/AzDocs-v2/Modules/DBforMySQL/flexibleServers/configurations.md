# configurations

Target Scope: resourceGroup

## Synopsis
Adds or updates a configuration setting on an existing Azure Database for MySQL Flexible Server.<br>
Can be found in the Server parameters section of the settings in the Azure portal for MySQL flexible servers.

## Description
This file declares the `configurations` child resource for a MySQL flexible server. Use this<br>
module to create or update a server-level configuration (name/value) on an existing flexible server.<br>
The target server must already exist; this module targets the `configurations` child resource.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| mySqlFlexibleServerName | string | <input type="checkbox" checked> | None | <pre></pre> | Server Name for the existing Azure MySQL flexible server to which the configuration will be applied. |
| mySqlConfigurationName | string | <input type="checkbox"> | None | <pre>'aad_auth_only'</pre> | The name of the MySQL configuration to set. For example, "aad_auth_only" or "activate_all_roles_on_login". <br>The list of allowed name values can be fetched on an existing MySQL server with: `az rest --method get --uri "https://management.azure.com/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>/providers/Microsoft.DBforMySQL/flexibleServers/<serverName>/configurations?api-version=2024-12-30"  |
| mySqlConfigurationSource | string? | <input type="checkbox" checked> | `'system-default'` or `'user-override'` | <pre></pre> | Optional. Source of the configuration value. Possible values include: "system-default", "user-override". |
| mySqlConfigurationValue | string | <input type="checkbox" checked> | None | <pre></pre> | The value to set for the MySQL configuration. |
| mySqlCurrentValue | string? | <input type="checkbox" checked> | None | <pre></pre> | Optional.The current value of the MySQL configuration. |

## Examples
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

## Links
- https://learn.microsoft.com/azure/mysql/flexible-server/
