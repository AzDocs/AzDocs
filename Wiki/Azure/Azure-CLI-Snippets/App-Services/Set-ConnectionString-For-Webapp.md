[[_TOC_]]

# Description
This snippet will set the appsettings on your appservice. It allows you to set the settings for specific slots or all slots.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | `App-Service-name` | Name of the app service to set the whitelist on. | 
| AppServiceConnectionString | `mysql1='Server=myServer;Database=myDB;Uid=myUser;Pwd=myPwd;'`| ConnectionString in the form of `<connectionstringname>='<connectionstring>'` |
| AppServiceConnectionStringType | `MySql` | Type of the connectionstring. Options are: `ApiHub`, `Custom`, `DocDb`, `EventHub`, `MySql`, `NotificationHub`, `PostgreSQL`, `RedisCache`, `SQLAzure`, `SQLServer`, `ServiceBus` |
| AppServiceDeploymentSlotName | `staging` |  Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# Code
[Click here to download this script](../../../../src/App-Services/Set-ConnectionString-For-Webapp.ps1)